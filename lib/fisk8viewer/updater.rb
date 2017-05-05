require 'fisk8viewer/utils'
require 'fisk8viewer/competition_summary'
require 'fisk8viewer/parsers'
require 'fisk8viewer/parser'
require 'fisk8viewer/isu_bio'

module Fisk8Viewer
  class Updater
    include Utils

    DEFAULT_PARSER = :isu_generic
    ACCEPT_CATEGORIES =
      [:MEN, :LADIES, :PAIRS, :"ICE DANCE",
       :"JUNIOR MEN", :"JUNIOR LADIES", :"JUNIOR PAIRS", :"JUNIOR ICE DANCE",
      ]
    
    def initialize(accept_categories: nil)
      @accept_categories =
        case accept_categories
        when String
          accept_categories.split(/ *, */).map(&:upcase).map(&:to_sym)
        else
          accept_categories
        end.presence || ACCEPT_CATEGORIES
    end
    
    def load_competition_list(yaml_filename)
      YAML.load_file(yaml_filename).map do |item|
        case item
        when String
          {url: item, parser: DEFAULT_PARSER}
        when Hash
          {url: item["url"], parser: item["parser"]}
        else
          raise "invalid format ('#{yaml_filename}'): has to be String or Hash"
        end
      end
    end
    def update_competitions(items)
      items.map do |item|
        update_competition(item[:url], parser_type: item[:parser])
      end
    end
    def update_competition(url, parser_type: :isu_generic)
      parser_klass =Fisk8Viewer::Parsers.registered[parser_type]
      raise "no such parser: '#{parser_type}'" if parser_klass.nil?
      
      parser = parser_klass.new
      logger.debug "** update competition: #{url} with '#{parser_type}'"
      
      if Competition.find_by(site_url: url)
        logger.debug "   alread exists"
        return if ENV['RACK_ENV'] == "production"
      end
      summary = Fisk8Viewer::CompetitionSummary.new(parser.parse_competition_summary(url))
      keys = [:name, :city, :country, :site_url, :start_date, :end_date,
              :competition_type, :short_name, :season,]
      competition = Competition.create(summary.slice(*keys))

      ## for each categories
      summary.categories.each do |category|
        next unless @accept_categories.include?(category.to_sym)
        
        result_url = summary.result_url(category)
        logger.debug " = update category result [%s]" % [category]
        update_category_result(result_url, competition: competition, parser: parser)

        ## for segments
        summary.segments(category).each do |segment|
          logger.debug "  - update scores on segment [#{category}/#{segment}]"

          score_url = summary.score_url(category, segment)
          parser.parse_score(score_url).each do |score_hash|
            score = update_score(score_hash, competition: competition, category: category, segment: segment)
            score.update(starting_time: summary.starting_time(category, segment))
          end
        end
      end
      competition
    end
    ################################################################
    def update_category_result(url, competition: , parser: )
      return [] if url.blank?

      parser.parse_category_result(url).map do |result_hash|
        keys = [:category, :rank, :skater_name, :nation, :points, :isu_number, :sp_ranking, :fs_ranking]
        param = {name: result_hash[:skater_name]}.merge(result_hash.slice(*[:isu_number, :nation, :category]))
          
        skater = find_or_create_skater(result_hash[:isu_number], result_hash[:skater_name], category: result_hash[:category], nation: result_hash[:nation])
        #result_hash[:skater_name] = skater.name

        logger.debug ".#%<rank>2d: '%{skater_name}' (%{isu_number}) [%{nation}] %{sp_ranking} / %{fs_ranking}" % result_hash
        cr = competition.category_results.create(result_hash.slice(*keys))
        skater.category_results << cr
        cr.update(skater: skater)
        cr
      end
    end
    ################################################################
    def update_score(score_hash, competition: , category: , segment: )
      ## skater
      skater = competition.category_results.find_by(category: category, skater_name: score_hash[:skater_name]).try(:skater) ||
        find_or_create_skater(nil, score_hash[:skater_name], category: category, nation: score_hash[:nation])
      #score_hash[:skater_name] = skater.name

      logger.debug "  ..%<rank>2d: '%{skater_name}' (%{nation}) %<tss>3.2f" % score_hash
      score_keys = [:skater_name, :rank, :starting_number, :nation,
              :starting_time, :result_pdf, :tss, :tes, :pcs, :deductions]
      score = competition.scores.create(score_hash.slice(*score_keys)) do |sc|
        sc.competition_name = competition.name
        sc.category = category
        sc.segment = segment
        sc.skater = skater
      end
      skater.scores << score
      
      ## technicals
      tech_keys = [:number, :element, :info, :base_value, :credit, :goe, :judges, :value]
      score_hash[:technicals].each do |element|
        score.technicals.create(element.slice(*tech_keys))
      end
      score.update(technicals_summary: score_hash[:technicals].map {|e| e[:element]}.join('/'))
      
      ## components
      comp_keys = [:component, :number, :factor, :judges, :value]
      score_hash[:components].each do |comp|
        score.components.create(comp.slice(*comp_keys))
      end
      score.update(components_summary: score_hash[:components].map {|c| c[:value]}.join('/'))

      score
    end
    ################################################################
    def update_skaters
      parser = Fisk8Viewer::ISU_Bio.new
      records = parser.parse_isu_bio_summary(@accept_categories)
      records.each do |hash|
        find_or_create_skater(hash[:isu_number], hash[:name], category: hash[:category], nation: hash[:nation])
      end
    end

    def update_isu_bio_details(skater=nil)
      logger.debug("update skaters bio details")

      skaters = (skater.present?) ? [skater] : Skater.order(:category)
      
      parser = Fisk8Viewer::ISU_Bio.new
      skaters.each do |skater|
        next if skater.isu_number.blank?
        next if skater.category != "MEN" && skater.category != "LADIES"
        next unless @accept_categories.include?(skater.category.to_sym)
        #next if skater.bio_updated_at.present?
        
        hash = parser.parse_isu_bio_details(skater.isu_number, skater.category)
        logger.debug("  update skater bio: #{hash[:name]} (#{skater.isu_number})")        
        keys = [:isu_number, :name, :nation, :category, :isu_bio,
                :coach, :choreographer, :birthday, :hobbies, :height, :club]
        skater.update(hash.slice(*keys))
        skater.update(bio_updated_at: Time.now)
      end
    end
    ################################################################
    def seniorize(category)
      sen_cat = category.to_s.gsub(/^JUNIOR /, '')
      (category.class == Symbol) ? sen_cat.to_sym : sen_cat
    end
    def find_skater_by_isu_number_name(isu_number, name)
      skater = Skater.find_by(isu_number: isu_number) if isu_number.present?
      skater ||= Skater.find_by(name: name)      
    end
    def find_or_create_skater(isu_number, name, nation:, category:)
      find_skater_by_isu_number_name(isu_number, name) || Skater.create do |skater|
        skater.isu_number = isu_number if isu_number.present?
        skater.isu_bio = isu_bio_url(isu_number) if isu_number.present?
        skater.name = name if name.present?
        skater.nation = nation if nation.present?
        skater.category = seniorize(category) if category.present?
        #logger.debug(skater.to_s + " created")
        logger.debug "%{name} (%{isu_number}) [%{nation}] <%{category}> created" % skater.attributes.symbolize_keys
        #logger.debug(" '%s' (%s) [%s] in {%s} created" % [skater.name, skater.isu_number, skater.nation, skater.category])
      end
    end
  end  ## class
end


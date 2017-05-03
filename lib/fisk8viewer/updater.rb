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
       :"JUNIOR MEN", :"JUNIOR LADIES", :"JUNIOR PAIRS", :"JUNIOR ICE DANCE",]
    
    def initialize(accept_categories: nil)
      @accept_categories = accept_categories ||ACCEPT_CATEGORIES
    end
    
    def load_config(yaml_filename)
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
      logger.debug " - update competition: #{url} with #{parser_type}"
      
      if Competition.find_by(site_url: url)
        logger.debug "   alread exists"
        #return
      end
      summary = Fisk8Viewer::CompetitionSummary.new(parser.parse_competition_summary(url))
      keys = [:name, :city, :country, :site_url, :start_date, :end_date,
              :competition_type, :short_name, :season,]
      competition = Competition.create(summary.slice(*keys))

      ## for each categories
      summary.categories.each do |category|
        next unless @accept_categories.include?(category.to_sym)
        
        result_url = summary.result_url(category)
        update_category_result(result_url, competition: competition, parser: parser)

        ## for segments
        summary.segments(category).each do |segment|
          #logger.debug "  - update segment result [#{category}/#{segment}]"
          #segment_result_url = summary.result_url(category, segment)
          #update_segment_result(segment_result_url, competition: competition, parser: parser)
          
          logger.debug "  - update scores on segment [#{category}/#{segment}]"

          score_url = summary.score_url(category, segment)
          #update_scores(score_url, competition: competition, parser: parser)
          parser.parse_score(score_url).each do |score_hash|
            score = update_score(score_hash, competition: competition, category: category, segment: segment)
            score.update(starting_time: summary.starting_time(category, segment))
          end

        end
      end
      competition
    end
    ################################################################
    def update_category_result(url, competition: nil, parser: nil)
      return [] if url.blank?
      raise if competition.nil? || parser.nil?
      logger.debug " = update category result"
      competition ||= Competition.new

      parser.parse_category_result(url).map do |result_hash|
        keys = [:category, :rank, :skater_name, :nation, :points, :isu_number, :sp_ranking, :fs_ranking]
        param = {name: result_hash[:skater_name]}.merge(result_hash.slice(*[:isu_number, :nation, :category]))
          
        skater = find_or_create_skater(param)
        #skater = Skater.find_by(isu_number: result_hash[:isu_number]) ||
        #Skater.find_by(name: result_hash[:skater_name]) || raise("no such skater #{result_hash[:isu_number]}/#{result_hash[:skater_name]}")
          #Skater.create(name: result_hash[:skater_name], result_hash.slice(*[:isu_number, :nation, :category]))
        #skater = find_or_create_skater(result_hash[:isu_number], result_hash.slice(*[:skater_name, :nation, :category]))
        result_hash[:skater_name] = skater.name
        cr = competition.category_results.create(result_hash.slice(*keys))
        skater.category_results << cr
        cr.update(skater: skater)
        cr
      end
    end
=begin
    ################################################################
    def update_segment_result(url, competition: nil, parser: nil)
      return [] if url.blank?
      raise if competition.nil? || parser.nil?
      logger.debug " = update segment result"
      competition ||= Competition.new
      
      parser.parse_segment_result(url).map do |result_hash|
        keys = [:category, :segment, :rank, :skater_name, :isu_number]
        sr = competition.segment_results.create(result_hash.slice(*keys))

        skater = Skater.find_by(isu_number: result_hash[:isu_number]) || raise
#        skater = find_or_create_skater(result_hash[:isu_number], result_hash.slice(*[:skater_name, :nation, :category]))
        skater.segment_results << sr
        sr.update(skater: skater)
        sr
      end
    end
=end
    ################################################################
    def update_scores(score_url, competition: nil, parser: nil)
      raise if competition.nil? || parser.nil?
    end
    def update_score(score_hash, competition: nil, category: nil, segment: nil)
      raies if competition.nil?
      
      ## skater
      ranking_key = (segment =~ /SHORT/) ? :sp_ranking : :fs_ranking      
      skater = competition.category_results.where(category: category, ranking_key => score_hash[:rank]).first.try(:skater) || raise
      score_hash[:skater_name] = skater.name
      
      #score_hash[:skater_name] = unify_skater_name(score_hash[:skater_name])
      logger.debug "  ..#{score_hash[:rank]}: #{score_hash[:skater_name]} (#{score_hash[:nation]})"
      score_keys = [:skater_name, :rank, :starting_number, :nation,
              :starting_time, :result_pdf, :tss, :tes, :pcs, :deductions]
      score = competition.scores.create(score_hash.slice(*score_keys))
      score.competition_name = competition.name
      score.category = category
      score.segment = segment
      score.skater = skater
      
      ## technicals
      tech_keys = [:number, :element, :info, :base_value, :credit, :goe, :judges, :value]
      score_hash[:technicals].each do |element|
        score.technicals.create(element.slice(*tech_keys))
      end
      score.technicals_summary = score_hash[:technicals].map {|e| e[:element]}.join('/')
      
      ## components
      comp_keys = [:component, :number, :factor, :judges, :value]
      score_hash[:components].each do |comp|
        score.components.create(comp.slice(*comp_keys))
      end
      score.components_summary = score_hash[:components].map {|c| c[:value]}.join('/')

      ##
      skater.scores << score
      score.save
      score
    end
    ################################################################
    def find_or_create_skater(isu_number:, name:, nation:, category:)
      skater = Skater.find_by(isu_number: isu_number) || Skater.find_by(name: name) || Skater.create do
        logger.debug(" '%s' (%s) [%s] in %s created" % [name, isu_number, nation, category])
      end
      skater.isu_number = isu_number if isu_number.present?
      skater.name = name if name.present?
      skater.nation = nation if nation.present?
      skater.category = category if category.present?
      skater.isu_bio = isu_bio_url(isu_number) if isu_number.present?
      skater.save
      skater
    end
    def update_skaters
      parser = Fisk8Viewer::ISU_Bio.new
      records = parser.parse_isu_summary(@accept_categories)
      records.each do |hash|
        find_or_create_skater(hash.slice(*[:isu_number, :name, :nation, :category]))
      end
    end

    def update_isu_bio_details(skater=nil)
      parser = Fisk8Viewer::ISU_Bio.new
      logger.debug("update skaters bio details")

      skaters =
        if skater.present?
          [skater]
        else
          update_skaters
          Skater.order(:category)
        end
      
      #Skater.order(:category).each do |skater|
      skaters.each do |skater|
        next if skater.isu_number.blank?
        next unless @accept_categories.include?(skater.category.to_sym)
        
        logger.debug("  update skater: #{skater.name} (#{skater.isu_number})")        
        hash = parser.parse_isu_bio_details(skater.isu_number, skater.category)
        keys = [:isu_number, :name, :nation, :category, :isu_bio,
                :coach, :choreographer, :birthday, :hobbies, :height, :club]
        skater.update(hash.slice(*keys))
      end
    end
=begin
    ################################################################
    def unify_skater_name(skater_name)
      @unify_skater_names ||= YAML.load_file(Padrino.root('config', 'unify_skater_name.yaml'))
      (un = @unify_skater_names[skater_name]) ? un : skater_name
    end

    def find_or_create_skater(skater_name, isu_number: nil, nation: nil, category: nil)
      Skater.find_or_create_by(name: unify_skater_name(skater_name)) do |skater|
        skater.attributes = {
          isu_number: isu_number,
          nation: nation,
          category: category,
        }
        skater.isu_bio = isu_bio_url(isu_number) if isu_number
        logger.debug "   skater '#{skater.name}'[#{skater.isu_number}] (#{skater.nation}) [#{skater.category}] created"
      end
    end
=end
  end  ## class
end


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
      raise "no such parser: '#{parser_type}'" unless defined?(parser_klass)
      
      parser = parser_klass.new
      logger.debug " - update competition: #{url} with #{parser_type}"
      
      if Competition.find_by(site_url: url)
        logger.debug "   alread exists"
        return
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
          logger.debug "  - update scores on segment [#{category}/#{segment}]"
          
          score_url = summary.score_url(category, segment)
          ## parse score and update
          parser.parse_score(score_url).each do |score_hash|
            score = update_score(score_hash, competition: competition)
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
        keys = [:category, :rank, :skater_name, :points]
        cr = competition.category_results.create(result_hash.slice(*keys))

        skater = find_or_create_skater(result_hash[:skater_name], result_hash.slice(*[:isu_number, :nation, :category]))
        skater.category_results << cr
        cr.update(skater: skater)
        cr
      end
    end

    ################################################################
    def update_score(score_hash, competition: nil)
      raies if competition.nil?

      score_hash[:skater_name] = unify_skater_name(score_hash[:skater_name])
      logger.debug "  ..#{score_hash[:rank]}: #{score_hash[:skater_name]} (#{score_hash[:nation]})"
      score_keys = [:competition_name, :category, :segment, :skater_name, :rank, :starting_number, :nation,
              :starting_time, :result_pdf, :tss, :tes, :pcs, :deductions]
      score = competition.scores.create(score_hash.slice(*score_keys))

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

      ## skater
      skater = find_or_create_skater(score.skater_name, category: score_hash[:category], nation: score_hash[:nation])

      skater.scores << score
      score.skater = skater
      score.save
      score
    end
    ################################################################
    def update_skater_bio
      logger.debug("update skaters")
      parser = Fisk8Viewer::ISU_Bio.new
      keys = [:isu_number, :isu_bio, :coach, :choreographer, :birthday, :hobbies, :height, :club]

      isu_number_hash =parser.scrape_isu_numbers

      Skater.order(:category).each do |skater|
        hash = isu_number_hash[skater.name]
        next if hash.blank?
        
        skater_hash = parser.scrape_skater(hash[:isu_number], hash[:category])
        logger.debug("  update skater: #{skater.name} (#{hash[:isu_number]})")
        
        skater.update(skater_hash.slice(*keys))
      end
    end
    ################################################################
    def find_or_create_skater(skater_name, isu_number: nil, nation: nil, category: nil)
      Skater.find_or_create_by(name: unify_skater_name(skater_name)) do |skater|
        skater.attributes = {
          isu_number: isu_number,
          nation: nation,
          category: category,
        }
        skater.isu_bio = isu_bio_url(isu_number) if isu_number
        skater.save
        logger.debug "   skater '#{skater.name}'[#{skater.isu_number}] (#{skater.nation}) [#{skater.category}] created"
      end
    end
  end  ## class
end


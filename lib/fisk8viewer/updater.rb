require 'fisk8viewer/logger'
require 'fisk8viewer/utils'
require 'fisk8viewer/competition_summary_adaptor'
require 'fisk8viewer/parser'
require 'fisk8viewer/isu_bio'

module Fisk8Viewer
  class Updater
    include Logger
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
          raise
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

      raise "no such parser class: '#{parser_type}'" if parser_klass.nil?
      parser = parser_klass.new
      logger.debug " - update competition: #{url} with #{parser_type}"
      
      if competition = Competition.find_by(site_url: url)
        logger.debug "   alread exists"
        return
      end
      data = Fisk8Viewer::CompetitionSummaryAdaptor.new(parser.parse_competition_summary(url))
      keys = [:name, :city, :country, :site_url, :start_date, :end_date,
              :competition_type, :short_name, :season,]
      competition = Competition.create(data.slice(*keys))

      ## for each categories
      data.categories.each do |category|
        next unless @accept_categories.include?(category.to_sym)
        
        result_url = data.result_url(category)
        update_category_result(result_url, competition: competition, parser: parser)

        ## for segments
        data.segments(category).each do |segment|
          logger.debug "  - update scores on segment [#{category}/#{segment}]"
          
          score_url = data.score_url(category, segment)
          ## parse score and update
          parser.parse_score(score_url).each do |score_hash|
            score = update_score(score_hash, competition: competition)
            score.update(starting_time: data.starting_time(category, segment))
          end
        end
      end
      competition
    end
    ################################################################
    def update_category_result(url, competition: nil, parser: nil)
      return [] if url.blank?
      raise if competition.nil?
      logger.debug " = update category result"
      competition ||= Competition.new
      keys = [:category, :rank, :skater_name, :points]
      #parser = Fisk8Viewer::Parser::CategoryResultParser.new
      results = parser.parse_category_result(url)
      results.map do |result_hash|
        cr = competition.category_results.create(result_hash.slice(*keys))

        skater = find_or_create_skater(result_hash[:skater_name], result_hash)
        skater.category_results << cr
        cr.update(skater: skater)
        cr
      end
    end

    ################################################################
    def update_score(score_hash, competition: nil)
      raies if competition.nil?
      keys = [:competition_name, :category, :segment,
              :skater_name, :rank, :starting_number, :nation,
              :starting_time, :result_pdf, :tss, :tes, :pcs, :deductions]
      score_hash[:skater_name] = unify_skater_name(score_hash[:skater_name])
      logger.debug "  ..#{score_hash[:rank]}: #{score_hash[:skater_name]} (#{score_hash[:nation]})"
      score = competition.scores.create(score_hash.slice(*keys))

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
      skater = find_or_create_skater(score.skater_name, score_hash)
      skater.scores << score
      score.skater = skater
      score.save
      score
    end
    ################################################################
    def update_skater_bio
      logger.debug("update skaters")
      parser = SkaterParser.new
      keys = [:isu_number, :isu_bio, :coach, :choreographer, :birthday, :hobbies, :height, :club]

      isu_number_hash =parser.scrape_isu_numbers

      Skater.order(:category).each do |skater|
        hash = isu_number_hash[skater.name]
        next if hash.blank?
        
        skater_hash = parser.parse_skater(hash[:isu_number], hash[:category])
        logger.debug("  update skater: #{skater.name} (#{hash[:isu_number]})")
        
        skater.update(skater_hash.slice(*keys))
      end
    end
    private
    def find_or_create_skater(skater_name, hash)
      Skater.find_or_create_by(name: unify_skater_name(skater_name)) do |skater|
        skater.attributes = hash.slice(*[:isu_number, :nation, :category])
        skater.isu_bio = isu_bio_url(hash[:isu_number]) if hash[:isu_number]
        logger.debug "   skater '#{skater.name}'[#{skater.isu_number}] (#{skater.nation}) [#{skater.category}] created"
      end
    end
  end  ## class
end


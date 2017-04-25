require 'fisk8viewer/competition_parsers'
require 'fisk8viewer/competition_parser'
require 'fisk8viewer/competition_summary_adaptor'

module Fisk8Viewer
  class Updater
    include Logger
    DEFAULT_PARSER_TYPE = :isu_generic
    
    def load_config(yaml_filename)
      YAML.load_file(yaml_filename).map do |item|
        if item.is_a? String
          {url: item, parser: DEFAULT_PARSER_TYPE}
        elsif item.is_a? Hash
          {url: item["url"], parser: item["parser"]}
        else
          raise
        end
      end
    end
    def update_competitions(items)
      items.each do |item|
        parser = Fisk8Viewer::CompetitionParsers.registered[item[:parser]].new
        update_competition(item[:url], parser: parser)
      end
    end
    def update_competition(url, parser: Fisk8Viewer::CompetitionParsers.registered[DEFAULT_PARSER_TYPE].new)
      logger.debug " - update competition: #{url}"

      if competition = Competition.find_by(site_url: url)
        logger.debug "   alread exists"
        return
      end
      data = Fisk8Viewer::CompetitionSummaryAdaptor.new(parser.parse_summary(url))

      keys = [:name, :city, :country, :site_url, :start_date, :end_date,
              :competition_type, :abbr, :season,]
      competition = Competition.create(data.slice(*keys))

      ## for each categories
      score_parser = Fisk8Viewer::ScoreParser.new
      data.categories.each do |category|
        result_url = data.result_url(category)
        
        logger.debug " - update category result of '#{category}'"
        results = parser.parse_category_result(result_url)
        results.each do |result_hash|
          keys = [:category, :rank, :skater_name, :points]
          cr = competition.category_results.create(result_hash.slice(*keys))

          skater = Skater.find_or_create_by(name: result_hash[:skater_name])
          skater.update(result_hash.slice(*[:nation, :category]))
          skater.category_results << cr
          cr.skater = skater; cr.save
        end
        
        ## for segments
        data.segments(category).each do |segment|
          logger.debug " - update scores on segment [#{category}/#{segment}]"
          
          additional_hash = {
            starting_time: data.starting_time(category, segment),
            competition_name: competition.name,
            category: category,
            segment: segment,
          }
          
          score_url = data.score_url(category, segment)    
          score_parser.parse(score_url).each do |score_hash|
            update_score(score_hash, score: competition.scores.create(additional_hash))
          end
        end
      end
    end
    ################################################################
    def update_score(score_hash, score: Score.create) 
      logger.debug "  ..#{score_hash[:rank]}:#{score_hash[:skater_name]} (#{score_hash[:nation]})"
      keys = [:skater_name, :rank, :starting_number, :nation,
              :starting_time, :result_pdf, :tss, :tes, :pcs, :deductions]
      score.update(score_hash.slice(*keys))
      
      ## technicals
      tech_keys = [:number, :element, :info, :base_value, :credit, :goe, :judges, :value]
      score_hash[:technicals].each do |element|
        score.technicals.create(element.slice(*tech_keys))
      end
      score[:technicals_summary] = score_hash[:technicals].map {|e| e[:element]}.join('/')
      
      ## components
      comp_keys = [:component, :number, :factor, :judges, :value]
      score_hash[:components].each do |comp|
        score.components.create(comp.slice(*comp_keys))
      end
      score[:components_summary] = score_hash[:components].map {|c| c[:value]}.join('/')

      ## skater
      sk_keys = [:nation, :category]
      skater = Skater.find_or_create_by(name: score.skater_name) do |skater|
        skater.update(score_hash.slice(*sk_keys))
      end
      skater.scores << score
      score.skater = skater
      score.save
    end
    ################
    def update_skaters
      logger.debug("update skaters")
      parser = SkaterParser.new
      keys = [:isu_number, :isu_bio, :coach, :choreographer, :birthday, :hobbies, :height, :club]
      
      [:MEN, :LADIES, :PAIRS, :"ICE DANCE"].each do |category|
        isu_number_hash = parser.scrape_isu_numbers(category)
        
        Skater.where(category: category).each do |skater|
          isu_number = isu_number_hash[skater.name]
          next if isu_number.blank? || skater[:isu_number].present?
          
          skater_hash = parser.parse_skater(isu_number, category)
          logger.debug("  update skater: #{skater.name} (#{isu_number})")

          skater.update(skater_hash.slice(*keys))
          skater.save
        end
      end
    end
  end  ## class
end


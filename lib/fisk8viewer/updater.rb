require 'fisk8viewer/competition_parsers'
require 'fisk8viewer/competition_parser'
require 'fisk8viewer/competition_adaptor'

module Fisk8Viewer
  class Updater
    include Logger
    include Utils
    
    def update_competitions(ary)
      ary.each do |item|
        if item.is_a? String
          url = item
          parser_type = :isu_generic
        elsif item.is_a? Hash
          url = item["url"]
          parser_type = item["parser"]
        end
        parser = Fisk8Viewer::CompetitionParsers.registered[parser_type].new
        update_competition(url, parser: parser)
      end
    end
    
    def update_competition(url, parser: nil)
      logger.debug " - update competition: #{url}"

      if competition = Competition.find_by(site_url: url)
        logger.debug "   alread exists"
        return
      end
      data = Fisk8Viewer::CompetitionAdaptor.new(parser.parse_summary(url))

      keys = [:name, :city, :country, :site_url, :start_date, :end_date,
              :competition_type, :abbr, :season,]
      competition = Competition.create(data.slice(*keys))

      ## for each categories
      score_parser = Fisk8Viewer::ScoreParser.new
      data.categories.each do |category|
        result_url = data.result_url(category)

        logger.debug " - update category [#{category}]"
        results = parser.parse_category_result(result_url)
        results.each do |result_hash|
          keys = [:category, :rank, :skater_name, :points]
          competition.category_results.create(result_hash.slice(*keys))
        end

        ## for segments
        data.segments(category).each do |segment|
          logger.debug " - update scores on segment [#{category}/#{segment}]"

          additional_hash = {
            starting_time: data.starting_time(category, segment),
            result_pdf: data.score_url(category, segment),
          }
          score_text = convert_pdf(additional_hash[:result_pdf], dir: "pdf")
          
          score_parser.parse(score_text).each do |score_hash|
            update_score(score_hash.merge(additional_hash)) do
              competition.scores.create
            end
          end
        end
      end
    end
    ################################################################
    def update_score(score_hash) 
      logger.debug "  ..#{score_hash[:rank]}:#{score_hash[:skater_name]}/#{score_hash[:category]}/#{score_hash[:segment]}/#{score_hash[:competition_name]}"
      keys = [:skater_name, :rank, :starting_number, :nation,
              :competition_name, :category, :segment, :starting_time, :result_pdf,
              :tss, :tes, :pcs, :deductions] # .each do |k|
      score = (block_given?) ? yield : Score.create
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


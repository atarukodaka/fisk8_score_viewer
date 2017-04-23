require 'fisk8viewer/competition_parser'
require 'fisk8viewer/competition_adaptor'

module Fisk8Viewer
  class Updater
    include Logger
    include Utils
    
    def update_competition(url, parser: nil)
      logger.debug " - update competition: #{url}"

      if competition = Competition.find_by(site_url: url)
        logger.debug "   alread exists"
        return
      end
      #competition_parser = Fisk8Viewer::CompetitionSummaryParser::ISU_Generic.new

      data = Fisk8Viewer::CompetitionAdaptor.new(parser.parse_summary(url))

      keys = [:name, :city, :country, :site_url, :start_date, :end_date,
              :competition_type, :abbr, :season,]
      competition = Competition.create(data.slice(*keys))

      ## for each categories
      score_parser = Fisk8Viewer::ScoreParser.new
      data.categories.each do |category|
        result_url = data.result_url(category)

=begin
        logger.debug " - update category [#{category}]"
        results = competition_parser.parse_category_result(result_url)
        results.each do |result_hash|
          rec = competition.category_results.create(category: category)
          [:rank, :skater_name, :points].each do |k|
            rec[k] = result_hash[k]
          end
            rec.save
        end
=end
        ## for segments
        data.segments(category).each do |segment|
          logger.debug " - update scores on segment [#{category}/#{segment}]"

          starting_time = data.starting_time(category, segment)
          score_url = data.score_url(category, segment)
          score_text = convert_pdf(score_url, dir: "pdf")
          
          ar = score_parser.parse(score_text)
          
          ar.each do |score_hash|
            score_url = data.score_url(category, segment)

            score = competition.scores.create
            update_score(score_hash.merge({starting_time: starting_time, result_pdf: score_url}), score)
            
          end
        end
      end
    end
    ################################################################
    def update_score(score_hash, score_rec)
      logger.debug "  ..#{score_hash[:rank]}:#{score_hash[:skater_name]}/#{score_hash[:category]}/#{score_hash[:segment]}/#{score_hash[:competition_name]}"
      [:skater_name, :rank, :starting_number, :nation,
       :competition_name, :category, :segment, :starting_time, :result_pdf,
       :tss, :tes, :pcs, :deductions].each do |k|
        score_rec[k] = score_hash[k]
      end
      ## skater
      skater = Skater.where(name: score_hash[:skater_name]).first.presence || Skater.create(name: score_hash[:skater_name], nation: score_hash[:nation], category: score_hash[:category])
      score_rec.skater_id = skater.id
      skater.scores << score_rec
      ## technicals
      score_hash[:technicals].each do |element|
        ar = [:number, :element, :info, :base_value, :credit,:goe, :judges, :value]
        hash = Hash[*ar.map {|k| [k, element[k]]}.flatten]
        score_rec.technicals.create(hash)
      end
      score_rec[:technicals_summary] = score_hash[:technicals].map {|e| e[:element]}.join('/')
      
      ## components
      score_hash[:components].each_with_index do |comp, i|
        ar = [:component, :factor, :judges, :value]
        hash = Hash[*ar.map {|k| [k, comp[k]]}.flatten]
        hash.merge!(number: i + 1)
        r = score_rec.components.create(hash)
      end
      score_rec[:components_summary] = score_hash[:components].map {|c| c[:value]}.join('/')
      score_rec.save
    end
    ################
    def update_skaters(force: false)
      logger.debug("update skaters")
      parser = SkaterParser.new

      [:MEN, :LADIES, :PAIRS, :"ICE DANCE"].each do |category|
        isu_number_hash = parser.scrape_isu_numbers(category)
        
        Skater.where(category: category).each do |skater|
          isu_number = isu_number_hash[skater.name]
          next if isu_number.blank?
          if skater[:isu_number].present? && force.blank?
            next
          end
          
          skater_hash = parser.parse_skater(isu_number, category)
          logger.debug("  update skater: #{skater.name} (#{isu_number})")
          
          [:isu_number, :isu_bio, :coach, :choreographer, :birthday, :hobbies, :height, :club].each do |key|
            skater[key] = skater_hash[key]
          end
          skater.save
        end
      end
    end
  end  ## class
end


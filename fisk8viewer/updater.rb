require 'active_record'
require 'fisk8viewer'
#require 'fisk8viewer/competition_parser'

module Fisk8Viewer
  class Updater
    include Logger
    include Utils
    
    def initialize
      establish_connection
    end

    def establish_connection
      require 'padrino'
      # require 'config/database'

      unless ENV['DATABASE_URL']
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/score_viewer_development.db')
      else
        postgres = URI.parse(ENV['DATABASE_URL'] || '')
        ActiveRecord::Base.configurations[:production] = {
          :adapter  => 'postgresql',
          :encoding => 'utf8',
          :database => postgres.path[1..-1],
          :username => postgres.user,
          :password => postgres.password,
          :host     => postgres.host
        }
        ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[:production])
      end

    end
    def update_competition(url)
      logger.debug " - update competition: #{url}"

      if competition = Competition.find_by(isu_site: url)
        logger.debug " already exists"
        return
      else
        competition = Competition.create
      end
      competition_parser = Fisk8Viewer::CompetitionParser.new
      competition_hash = competition_parser.parse(url)

      keys = [:name, :city, :country, :isu_site, :start_date, :end_date,
              :competition_type, :abbr, :season,]
      keys.each {|k|
        competition[k] = competition_hash[k]
      }
      competition.save
      
      ## category
      score_parser = Fisk8Viewer::ScoreParser.new

      ## for each categories
      competition_hash[:result_summary].each do |e|
        category = e[:category]
        segment = e[:segment]
        result_url = e[:result_url]
        score_url = e[:score_url]

        if segment.blank?    ## category result
          logger.debug " - update category [#{category}]"
          results = competition_parser.parse_category_result(result_url)
          results.each do |result_hash|
            rec = competition.category_results.create(category: category)
            [:rank, :skater_name, :points].each do |k|
              rec[k] = result_hash[k]
            end
            rec.save
          end
        else    ## segment scores
          logger.debug " - update scores on segment [#{category}/#{segment}]"
          score_text = convert_pdf(score_url, dir: "pdf")
          ar = score_parser.parse(score_text)
          ar.each do |score_hash|
            elem = competition_hash[:time_schedule].select {|e| e[:category] == category && e[:segment] == segment}
            starting_time = (elem.present?) ? elem.first[:time]  : nil
            score_hash.merge!(date: starting_time, result_pdf: score_url)
            score_rec = competition.scores.create
            update_score(score_hash, score_rec)
          end
        end
      end
    end
    ################################################################
    def update_score(score_hash, score_rec)
      logger.debug "  ..#{score_hash[:rank]}:#{score_hash[:skater_name]}/#{score_hash[:category]}/#{score_hash[:segment]}/#{score_hash[:competition_name]}"
      [:skater_name, :rank, :starting_number, :nation,
       :competition_name, :category, :segment, :date, :result_pdf,
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
    def update_skaters
      logger.debug("update skaters")
      parser = SkaterParser.new

      [:MEN, :LADIES, :PAIRS, :"ICE DANCE"].each do |category|
        isu_number_hash = parser.scrape_isu_numbers(category)
        
        Skater.where(category: category).each do |skater|
          isu_number = isu_number_hash[skater.name]
          next if isu_number.blank?
          next if skater[:isu_number].present?
          
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


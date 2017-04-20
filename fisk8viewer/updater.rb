require 'active_record'
#require 'fisk8viewer/competition_parser'

module Fisk8Viewer
  class Updater
    def establish_connection
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
    def update_competitions(urls)
      competition_parser = Fisk8Viewer::CompetitionParser.new
      urls.each do |url|
        puts "* parsing #{url}..."
        hash = competition_parser.parse(url)
        puts " - update competition"
        comp = update_competition(hash[:competition])
        if comp
          puts " - update scores"
          update_score(hash[:scores], comp)
        end
      end
    end
    def update_competition(competition_hash)
      establish_connection()
      #binding.pry
      #Competition.connection
      unless Competition.where(name: competition_hash[:name]).empty?
        puts "already registered"
        return nil
      end

      competition = Competition.create
      keys = [:name, :city, :country, :isu_site, :start_date, :end_date,
              :competition_type, :abbr, :season,
             ] 
      keys.each {|k|
        competition[k] = competition_hash[k]
      }
      ## category rank
      puts " - update category result"
      competition_parser = Fisk8Viewer::CompetitionParser.new
      competition_hash[:categories].each do |category, value|
        result_url = value[:result_url]
        ar = competition_parser.parse_category_result(result_url)
        #binding.pry
        ar.each do |result_hash|
          category_result = competition.category_results.create(rank: result_hash[:ranking], skater_name: result_hash[:skater_name], points: result_hash[:points], category: category.upcase)
        end
      end
      competition.save
      competition
    end
    ################################################################
    def update_score(scores, competition_record)
      establish_connection()
      scores.each do |score|
        puts "  ..#{score[:skater_name]}/#{score[:category]}/#{score[:segment]}/#{score[:competition_name]}"
        score_rec = competition_record.scores.create
        [:skater_name, :rank, :starting_number, :nation,
         :competition_name, :category, :segment, :date, :result_pdf,
         :tss, :tes, :pcs, :deductions].each do |k|
          score_rec[k] = score[k]
        end
        ## skater
        skater = Skater.where(name: score[:skater_name]).first.presence || Skater.create(name: score[:skater_name], nation: score[:nation], category: score[:category])
        score_rec.skater_id = skater.id
        skater.scores << score_rec
        
        ## technicals
        score[:technicals].each do |element|
          ar = [:number, :element, :info, :base_value, :credit,:goe, :judges, :value]
          hash = Hash[*ar.map {|k| [k, element[k]]}.flatten]
          r = score_rec.technicals.create(hash)
        end
        score_rec[:technicals_summary] = score[:technicals].map {|e| e[:element]}.join('/')

        ## components
        score[:components].each_with_index do |comp, i|
          ar = [:component, :factor, :judges, :value]
          hash = Hash[*ar.map {|k| [k, comp[k]]}.flatten]
          hash.merge!(number: i + 1)
          r = score_rec.components.create(hash)
        end
        score_rec[:components_summary] = score[:components].map {|c| c[:value]}.join('/')
        score_rec.save
      end
    end

    def update_skaters
      establish_connection()
      parser = SkaterParser.new
      skaters_hash = parser.scrape_isu_bio
      
      Skater.order("id DESC").each do |skater|
        ar = skaters_hash.select {|h| h[:name] == skater.name}
        next if ar.blank?
        hash = ar.first
        skater_bio = parser.parse_skater(hash[:isu_number], hash[:category])
        
        [:nation, :category, :isu_number, :isu_bio, :coach, :choreographer, :birthday, :hobbies, :height, :club].each do |key|
          skater[key] = skater_bio[key]
        end
        skater.save
      end
    end
  end  ## class
end


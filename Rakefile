lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler/setup'
require 'padrino-core/cli/rake'
require 'rake/clean'

require 'yaml'
require 'pry-byebug'

require 'fisk8viewer'

PadrinoTasks.use(:database)
PadrinoTasks.use(:activerecord)
PadrinoTasks.init

task :default => :server

task :server do
  system 'bundle exec padrino start -h 0.0.0.0'
end

task update: :update_competitions do
end

task :update_competitions => :update_env do
  number = (ENV["number"] || 0).to_i

  accept_categories = (e = ENV['accept_categories']) ? e.split(/,/).map(&:to_sym) : nil
  updater = Fisk8Viewer::Updater.new(accept_categories: accept_categories)
  items = updater.load_config(Padrino.root("config", "competitions.yaml"))
  items = items.reverse.first(number) if number > 0
  updater.update_competitions(items)
end

task :update_skater_bio => :update_env do  
  updater = Fisk8Viewer::Updater.new
  updater.update_skater_bio
end

task :parse_score => :update_env do
  pdf_url = ENV["url"]
  score_parser = Fisk8Viewer::ScoreParser.new
  include Fisk8Viewer::Utils

  ar = score_parser.parse(pdf_url)
  binding.pry
  puts ar.inspect
end

task :cleanup => :update_env do
  updater = Fisk8Viewer::Updater.new
  updater.cleanup
end

task :unify_skater_name => :update_env do
  ## check and correct 'HYOUKI-YURE' (name differency). e.g. Yuria, Juria
  ##
  parser = Fisk8Viewer::SkaterParser.new
  altered_hash = {}
  isu_hash = parser.scrape_isu_numbers()
  Skater.group(:isu_number).count.select {|k, v| v > 1 }.map do |isu_number, cnt|
    logger.debug "#{isu_number}:"
    altered_skaters = []
    registered_skater =nil
    Skater.where(isu_number: isu_number).map do |skater|
      logger.debug "  - #{skater.name} (#{skater.scores.count}) %s" % [(isu_hash[skater.name]) ? "(*)" : ""]
      
      if isu_hash[skater.name]
        registered_skater = skater
      else
        altered_skaters << skater
      end
    end
    altered_skaters.map do |alt_skater|
      altered_hash[alt_skater] = registered_skater
    end
  end

  ## update records of altered-skater
  puts "unify the altered-named skaters/scores ? "
  
  if STDIN.gets.to_s =~ /[Yy]/
    altered_hash.each do |alt_skater, registered_skater|
      puts "'#{alt_skater.name}': '#{registered_skater.name}'"
      alt_skater.scores.each do |score|
        score.skater = registered_skater
        score.skater_name = registered_skater.name
        score.save
        registered_skater.scores << score
      end
      alt_skater.category_results.each do |cr|
        cr.skater = registered_skater
        cr.save
        registered_skater.category_results << cr
      end
      registered_skater.save
      alt_skater.destroy
    end
  end
  puts "*** Add below into '#{Padrino.root('config', 'unify_skater_name.yaml')}'"
  altered_hash.each do |alt_skater, registered_skater|
    puts %Q["#{alt_skater.name}": "#{registered_skater.name}"]
  end
end

task :update_env => :environment do
  ActiveRecord::Base.logger = Logger.new('log/sql.log')
end



task :test => :spec do
end

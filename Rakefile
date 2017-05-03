lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler/setup'
require 'padrino-core/cli/rake'
require 'rake/clean'

require 'yaml'
require 'pry-byebug'

require 'fisk8viewer/updater'

PadrinoTasks.use(:database)
PadrinoTasks.use(:activerecord)
PadrinoTasks.init

task :default => :server

task :server do
  system 'bundle exec padrino start -h 0.0.0.0'
end

task :update => :update_competitions do
end

task :update_competitions => :update_env do
  number = (ENV["number"] || 0).to_i

  updater = Fisk8Viewer::Updater.new(accept_categories: ENV['accept_categories'])
  items = updater.load_competition_list(Padrino.root("config", "competitions.yaml"))
  items = items.reverse.first(number) if number > 0
  updater.update_competitions(items)
end


task :parse_score => :update_env do
  pdf_url = ENV["url"]
  score_parser = Fisk8Viewer::ScoreParser.new
  include Fisk8Viewer::Utils

  ar = score_parser.parse(pdf_url)
  puts ar.inspect
end

task :update_skaters => :update_env do  
  updater = Fisk8Viewer::Updater.new(accept_categories: ENV['accept_categories'])
  updater.update_skaters
end

task :update_isu_bio_details => :update_env do  
  updater = Fisk8Viewer::Updater.new(accept_categories: ENV['accept_categories'])
  updater.update_isu_bio_details
end


task :update_env => :environment do
  ActiveRecord::Base.logger = Logger.new('log/sql.log')
end

task :test => :spec do
end

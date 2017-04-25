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

task update: [:update_competitions, :update_skaters] do
end

task :update_competitions => :environment do
  ActiveRecord::Base.logger = Logger.new('log/sql.log')
  number = (ENV["number"] || 0).to_i
  
  updater = Fisk8Viewer::Updater.new
  items = updater.load_config(Padrino.root("config", "competitions.yaml"))
  items = items.reverse.first(number) if number > 0
  updater.update_competitions(items)
end

task :update_skaters => :environment do  
  updater = Fisk8Viewer::Updater.new
  updater.update_skaters
end

task :parse_score => :environment do
  pdf_url = ENV["url"]
  score_parser = Fisk8Viewer::ScoreParser.new
  include Fisk8Viewer::Utils
  
  score_text = convert_pdf(pdf_url, dir: "pdf")
  ar = score_parser.parse(score_text)
  puts ar.inspect
end

task :test => :spec do
end

lib = File.expand_path('../', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler/setup'
require 'padrino-core/cli/rake'
require 'rake/clean'
require 'yaml'

PadrinoTasks.use(:database)
PadrinoTasks.use(:activerecord)
PadrinoTasks.init

require 'pry-byebug'

require 'active_record'
require 'fisk8viewer'

task :default => :server

task :server do
  system 'bundle exec padrino start -h 0.0.0.0'
end

task update: [:update_competitions, :update_skaters] do
end

task :update_competitions => :environment do
  competitions = YAML.load_file("config/competitions.yaml")

  updater = Fisk8Viewer::Updater.new
  number = (ENV["number"] || 1).to_i

  [competitions.last(number).reverse].flatten.each do |item|
    if item.is_a? String
      url = item
      summary_parser_type = :isu_generic
    elsif item.is_a? Hash
      url = item["url"]
      summary_parser_type = item["summary_parser"]
    end
    updater.update_competition(url, summary_parser_type: summary_parser_type)
  end
end

task :update_skaters => :environment do  
  updater = Fisk8Viewer::Updater.new
  force = ENV['force'].try(:to_sym)
  updater.update_skaters(force: force)
end

task :parse_score => :environment do
  pdf_url = ENV["url"]
  score_parser = Fisk8Viewer::ScoreParser.new
  include Fisk8Viewer::Utils
  
  score_text = convert_pdf(pdf_url, dir: "pdf")
  ar = score_parser.parse(score_text)
  puts ar.inspect
end

task :foo => :bar do
  binding.pry
  puts ENV['foo']
  puts ENV['bar']
  
  puts Padrino.root("db", "score.db")
end


task :bar => :environment do
  bar = :bar
end

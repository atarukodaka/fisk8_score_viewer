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

task :update_skaters => :update_env do  
  accept_categories = (e = ENV['accept_categories']) ? e.split(/,/).map(&:to_sym) : nil
  updater = Fisk8Viewer::Updater.new(accept_categories: accept_categories)
  updater.update_skaters
end

task :parse_score => :update_env do
  pdf_url = ENV["url"]
  score_parser = Fisk8Viewer::ScoreParser.new
  include Fisk8Viewer::Utils

  ar = score_parser.parse(pdf_url)
  binding.pry
  puts ar.inspect
end

task :unify_skater_name => :update_env do
  ## check and correct name differency btw sources. e.g. Yuria or Juria
  ##
  parser = Fisk8Viewer::ISU_Bio.new
  altered_names = {}
  isu_names = parser.scrape_isu_numbers()

  Skater.order(:name).each do |skater|
    isu_name = isu_names.select {|k, v| v[:isu_number] == skater.isu_number}.keys.first
    if isu_name.present? && isu_name != skater.name
      altered_names[skater.name] = isu_name
      logger.debug(" '#{skater.name}' should be registed as '#{isu_name}'")
    end
  end
=begin
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
=end
  
  ## update records of altered-skater
  if !altered_names.empty?
    unify_filename = Padrino.root('config', 'unify_skater_name.yaml')
    puts "*** Add below into '#{unify_filename}' ? [y/n]"
    if STDIN.gets.to_s =~ /[Yy]/
      FileUtils.copy(unify_filename, "#{unify_filename}-bak")  # take backup
      File.open(unify_filename, "a") do |f|
        altered_names.each do |altered_name, isu_name|
          f.puts %Q["#{altered_name}": "#{isu_name}"]
        end
        logger.debug(" done.")
      end  # file
    end
  end
end

task :update_env => :environment do
  ActiveRecord::Base.logger = Logger.new('log/sql.log')
end

task :test => :spec do
end

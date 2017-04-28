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

task :update_competitions => :update_env do
  number = (ENV["number"] || 0).to_i
  
  updater = Fisk8Viewer::Updater.new
  items = updater.load_config(Padrino.root("config", "competitions.yaml"))
  items = items.reverse.first(number) if number > 0
  updater.update_competitions(items)
end

task :update_skaters => :update_env do  
  updater = Fisk8Viewer::Updater.new
  updater.update_skaters
end

task :parse_score => :update_env do
  pdf_url = ENV["url"]
  score_parser = Fisk8Viewer::ScoreParser.new
  include Fisk8Viewer::Utils
  
  score_text = convert_pdf(pdf_url, dir: "pdf")
  ar = score_parser.parse(score_text)
  puts ar.inspect
end

task :validate => :update_env do
  ## skater
  Skater.all.each do |skater|
    [:name, :nation, :category].each do |key|
      logger.warn "  !! #{key.to_s.upcase} EMPTY: #{skater.name}/#{skater.nation}#{skater.category}" if skater[key].blank?
    end

    # has scores?
    logger.warn "  !! HAS NO SCORES: #{skater.name}" if skater.scores.count == 0
  end

  ## competition, scores
  Competition.all.each do |competition|
    logger.debug "competition: #{competition.name}"
    competition.scores.each do |score|
      logger.debug " score: #{score.category}/#{score.segment}: #{score.rank}: #{score.skater_name}"
      ## result
      [:skater_name, :competition_name, :competition_id, :category, :segment,
       :starting_time, :tss, :tes, :pcs, :deductions, :result_pdf,].each do |key|
        logger.warn "  !! #{key.to_s.upcase} EMPTY" if score[key].blank?
      end
      ## technicals
      score.technicals.each_with_index do |element, i|
        logger.warn "   !! ELEMENT EMPTY: #{i+1}" if element.element.blank?
        logger.warn "   !! ELEMENT MISSING: #{i+1}" if element.number != i + 1
        logger.warn "   !! VALUE INVALID: #{i+1}" if element.value.blank?
      end
      ## components
    end
  end

  
end

task :cleanup => :update_env do
  updater = Fisk8Viewer::Updater.new
  updater.cleanup
end

task :update_env => :environment do
  ActiveRecord::Base.logger = Logger.new('log/sql.log')
end



task :test => :spec do
end

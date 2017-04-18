#lib = File.expand_path('../lib', __FILE__)
#$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler/setup'
require 'padrino-core/cli/rake'
require 'rake/clean'

PadrinoTasks.use(:database)
PadrinoTasks.use(:activerecord)
PadrinoTasks.init

require 'pry-byebug'

require 'active_record'
require './models/score'
require './models/competition'
require './models/skater'

require './fisk8viewer/competition_parser'
require './fisk8viewer/skater_parser'
require './fisk8viewer/score_parser'
require './fisk8viewer/updater'

task :default => :test

task :server do
  system 'bundle exec padrino start --port 1234 -h 0.0.0.0'
end

task :update_skaters do
  
  updater = Fisk8Viewer::Updater.new
  updater.update_skaters
end

task :update do

  urls = [
          ## 2013-14
          "http://www.isuresults.com/results/owg2014/",
          
          ## 2015-16
          "http://www.isuresults.com/results/season1516/gpusa2015/",
          "http://www.isuresults.com/results/season1516/gpcan2015/",
          "http://www.isuresults.com/results/season1516/gpchn2015/",
          "http://www.isuresults.com/results/season1516/gpfra2015/",
          "http://www.isuresults.com/results/season1516/gprus2015/",
          "http://www.isuresults.com/results/season1516/gpjpn2015/",
          "http://www.isuresults.com/results/season1516/gpf1516/",
          "http://www.isuresults.com/results/season1516/fc2016/",          
          "http://www.isuresults.com/results/season1516/wc2016/",
          
          ## 2016-17
          "http://www.isuresults.com/results/season1617/gpusa2016/",
          "http://www.isuresults.com/results/season1617/gpcan2016/",
          "http://www.isuresults.com/results/season1617/gpchn2016/",
          "http://www.isuresults.com/results/season1617/gpfra2016/",
          "http://www.isuresults.com/results/season1617/gprus2016/",
          "http://www.isuresults.com/results/season1617/gpjpn2016/",
          "http://www.isuresults.com/results/season1617/gpf1617/",
          "http://www.isuresults.com/results/season1617/fc2017/",          
          "http://www.isuresults.com/results/season1617/wc2017/",
         ]
  updater = Fisk8Viewer::Updater.new
  num = 1
  updater.update_competitions([urls.last(num)].flatten)
end

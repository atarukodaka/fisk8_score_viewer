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
require './fisk8viewer/score_parser'
require './fisk8viewer/updater'

task :default => :test

task :server do
  system 'bundle exec padrino start --port 1234 -h 0.0.0.0'
end

task :update do
  comp = {
    season: '2011-12',
    type: :grand_prix,  # :olympic,
    subtype: :usa, # :can, :chn, :fra, :jpn, :final / :sochi
  }
  urls = [
          ## 2011-12
          "http://www.isuresults.com/results/gpusa2011/",
          "http://www.isuresults.com/results/gpcan2011/",
          "http://www.isuresults.com/results/gpchn2011/",
          "http://www.isuresults.com/results/gpfra2011/",
          "http://www.isuresults.com/results/gprus2011/",
          "http://www.isuresults.com/results/gpjpn2011/",
          "http://www.isuresults.com/results/gpf1112/",
          "http://www.isuresults.com/results/fc2012/",          
          "http://www.isuresults.com/results/wc2012/",
          
          ## 2012-3
          "http://www.isuresults.com/results/gpusa2012/",
          "http://www.isuresults.com/results/gpcan2012/",
          "http://www.isuresults.com/results/gpchn2012/",
          "http://www.isuresults.com/results/gpfra2012/",
          "http://www.isuresults.com/results/gprus2012/",
          "http://www.isuresults.com/results/gpjpn2012/",
          "http://www.isuresults.com/results/gpf1213/",
          "http://www.isuresults.com/results/fc2013/",          
          "http://www.isuresults.com/results/wc2013/",
          
          ## 2013-4
          "http://www.isuresults.com/results/gpusa2013/",
          "http://www.isuresults.com/results/gpcan2013/",
          "http://www.isuresults.com/results/gpchn2013/",
          "http://www.isuresults.com/results/gpfra2013/",
          "http://www.isuresults.com/results/gprus2013/",
          "http://www.isuresults.com/results/gpjpn2013/",
          "http://www.isuresults.com/results/gpf1314/",
          "http://www.isuresults.com/results/fc2014/",          
          "http://www.isuresults.com/results/wc2014/",
          "http://www.isuresults.com/results/owg2014/",
          
          ## 2014-15
          "http://www.isuresults.com/results/gpusa2014/",
          "http://www.isuresults.com/results/gpcan2014/",
          "http://www.isuresults.com/results/gpchn2014/",
          "http://www.isuresults.com/results/gpfra2014/",
          "http://www.isuresults.com/results/gprus2014/",
          "http://www.isuresults.com/results/gpjpn2014/",
          "http://www.isuresults.com/results/gpf1415/",
          "http://www.isuresults.com/results/fc2015/",          
          "http://www.isuresults.com/results/wc2015/",
          
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
  num = 100
  updater.update_competitions([urls.last(num)].flatten)
end

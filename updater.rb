lib = File.expand_path('lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pry-byebug'
require 'active_record'
require 'mechanize'

require './models/score'
require './models/competition'
require './models/skater'

require 'fisk8viewer/competition_parser'
require 'fisk8viewer/score_parser'
require 'fisk8viewer/updater'

urls = [
        "http://www.isuresults.com/results/season1617/gpusa2016/",
        "http://www.isuresults.com/results/season1617/gpcan2016/",
        "http://www.isuresults.com/results/season1617/gpchn2016/",
        "http://www.isuresults.com/results/season1617/gpfra2016/",
        "http://www.isuresults.com/results/season1617/gprus2016/",
        "http://www.isuresults.com/results/season1617/gpjpn2016/",
        "http://www.isuresults.com/results/season1617/gpf1617/",
        "http://www.isuresults.com/results/season1617/fc2017/",          
        "http://www.isuresults.com/results/season1617/wc2017/"]

updater = Fisk8Viewer::Updater.new
updater.update_competitions([urls.last(1)].flatten)

competition_parser = Fisk8Viewer::CompetitionParser.new

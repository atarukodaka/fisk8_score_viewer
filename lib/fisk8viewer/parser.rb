require 'mechanize'


module Fisk8Viewer
  class Parser
    module Scraper
      def get_url(url)
        @agent ||= Mechanize.new
        page = @agent.get(url)
      end
    end
    require 'fisk8viewer/parser/competition_summary_parser'
    require 'fisk8viewer/parser/category_result_parser'
    require 'fisk8viewer/parser/score_parser'

    include CompetitionSummaryParser
    include CategoryResultParser
    include ScoreParser
  end ## Parser module
end

module Fisk8Viewer
  module Parsers
    @registered = {}
    class << self
      attr_reader :registered
      def register(key, klass)
        @registered[key] = klass
      end
    end
  end
end


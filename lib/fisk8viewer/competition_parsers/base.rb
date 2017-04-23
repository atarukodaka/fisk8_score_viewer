require 'fisk8viewer/competition_parsers'

require 'mechanize'

module Fisk8Viewer
  module CompetitionParser
    class Base
      attr_reader :agent
      
      def initialize
        @agent = Mechanize.new
      end

      def parse_summary(url)
        {result_summary: [], time_schedule: []}
      end
      def parse_category_result(url)
        []
      end
      Fisk8Viewer::CompetitionParsers.register(:base, self)
    end
  end ## class
end

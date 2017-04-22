require 'mechanize'

module Fisk8Viewer
  module CompetitionSummaryParser
    @registered = {}

    class << self
      attr_reader :registered
      
      def register(key, klass)
        @registered[key] = klass
      end
    end

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
      # Fisk8Viewer::CompetitionSummaryParser.register(:base, self)
    end
  end  ## module
end



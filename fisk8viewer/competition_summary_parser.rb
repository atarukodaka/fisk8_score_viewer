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
      end
      def parse_category_result(url)
      end
    end
  end  ## module
end



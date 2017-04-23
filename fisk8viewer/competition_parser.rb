# -*- coding: utf-8 -*-

require 'fisk8viewer/competition_summary_parser/isu_generic'
require 'fisk8viewer/competition_summary_parser/wtt_jsf'

module Fisk8Viewer
  class CompetitionParser
    include Logger
    @registered = {}

    class << self
      attr_reader :registered
      def register(key, klass)
        @registered[key] = klass
      end
    end
    
    ## delegation
    extend Forwardable
    def_delegators :@summary_parser, :parse_summary, :parse_category_result
    
    def initialize(summary_parser_type: :isu_generic)
      @summary_parser_type = summary_parser_type
      @summary_parser = Fisk8Viewer::CompetitionSummaryParser.registered[summary_parser_type].new
    end

    def parse(url)
      logger.debug  "  parsing #{url} with #{@summary_parser_type}..."
      res = parse_summary(url)
      
    end
  end ## class
end



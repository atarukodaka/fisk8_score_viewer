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
      
      ## type
      res[:competition_type] =
        case res[:name]
        when /^ISU GP/, /^ISU Grand Prix/
          :gp
        when /Olymic/
          :olympic
        when /^ISU World Figure/
          :world
        when /^ISU Four Continents/
          :fc
        when /^ISU European/
          :europe
        when /^ISU World Team/
          :team

        when /^ISU World Junior/
          :jworld
        when /^ISU JGP/, /^ISU Junior Grand Prix/
          :jgp
        else
          :unknown
        end

      ## dates
      res[:start_date] = res[:time_schedule].map {|e| e[:time]}.min
      res[:end_date] = res[:time_schedule].map {|e| e[:time]}.max

      ## season
      if res[:start_date].present?
        year, month = res[:start_date].year, res[:start_date].month
        year -= 1 if month <= 6
        res[:season] = "%04d-%02d" % [year, (year+1) % 100]
      end
      res
    end
  end ## class
end



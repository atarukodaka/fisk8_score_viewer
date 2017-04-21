# -*- coding: utf-8 -*-

require 'active_support/core_ext/time/zones'
require 'mechanize'
require 'uri'
require 'forwardable'

require 'fisk8viewer/competition_summary_parsers/isu_generic'

module Fisk8Viewer
  class CompetitionParser
    include Logger
    @registered = {}

    class << self
      attr_reader :registered
      def register(key, klass)
        binding.pry
        @registered[key] = klass
      end
    end
    
    ## delegation
    extend Forwardable
    def_delegators :@summary_parser, :parse_summary, :parse_category_result
    
    def initialize(summary_parser_type: :isu_generic)
      @summary_parser = self.class.registered[summary_parser_type].new
      
    end
    
    def parse(url)
      logger.debug  "  parsing #{url}..."
      res = parse_summary(url)
      binding.pry
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

=begin      
      ## abbr
      uri = URI.parse(url)
      res[:abbr] = uri.path.split('/').last
=end

      ## season
      year, month = res[:start_date].year, res[:start_date].month
      year -= 1 if month <= 6
      res[:season] = "%04d-%02d" % [year, (year+1) % 100]
      
      res
    end
  end
  module CompetitionSummaryParser
    class ISUGeneric
      def initialize
        @agent = Mechanize.new
        @nbsp = Nokogiri::HTML.parse("&nbsp;").text
      end
      ################
      def normalize_timezone(tz)
        if tz =~ /^UTC(.*)$/
          tz = $1.to_i
        end
        return tz || "UTC"
      end
      def search_table_by_first_header(page, str)
        page.search("table").each {|table|
          elem =  table / "./tr[1]/th[1]"
          return table if elem.text.gsub(@nbsp, " ") == str
          elem =  table / "./tr[1]/td[1]"
          return table if elem.text.gsub(@nbsp, " ") == str
        }
        return nil
      end
      def search_main_summary_table(page)
        search_table_by_first_header(page, "Category") || search_table_by_first_header(page, "カテゴリー")
      end
      def search_time_schedule_table(page)
        search_table_by_first_header(page, "Date")
      end
      def get_href_on_td(site_url, td)
        return "" if td.nil? || td.search("a").empty?
        return URI.join(site_url, td.search("a").attribute("href")).to_s
      end

      ################################################################
      def parse_summary(site_url, offset_timezone="UTC")
        data = {}
        category_data = {}

        category = ""
        return {} if site_url.nil? || site_url == ""
        page = @agent.get(site_url)
        binding.pry
        data[:name] = page.title
        city_country = page.search("td.caption3").first.inner_text
        data[:city], data[:country] = city_country.split(/ *\/ */)
        data[:isu_site] = site_url

        main_summary_table =  search_main_summary_table(page)
        return {} if main_summary_table.nil?

        main_summary_table.search("tr")[1..-1].each {|tr|
          tds = tr / "td"
          next if tds.empty?   # || tds[0].text =~ /^#{@nbsp}*$/

          if tds[0].text != "" && tds[0].text.ord != 160
            category = tds[0].text
            entry_url = get_href_on_td(site_url, tds[2])
            result_url = get_href_on_td(site_url, tds[3])
            category_data[category] = {entry_url: entry_url, result_url: result_url, segment: {}}
          elsif tds[1].text != ""
            next if category == ""   # for team trohpy
            segment = tds[1].text
            starting_order_url = get_href_on_td(site_url, tds[3])
            judge_score_url = get_href_on_td(site_url, tds[4])

            if category_data[category][:segment][segment].nil?
              category_data[category][:segment][segment] = {}
            end
            category_data[category][:segment][segment][:order_url] = starting_order_url
            category_data[category][:segment][segment][:score_url] = judge_score_url
          end
        }

        ## time schedule
        dates = []  ## to get start_date and end_date
        if time_schedule_table = search_time_schedule_table(page)
          date = time = ""
          time_schedule_table.search("tr").each {|tr|
            tds = tr / "td"
            next if tds[0].nil?
            if tds[0].text != ""
              date = tds[0].text
            else
              time = tds[1].text
              category = tds[2].text
              segment = tds[3].text

              Time.zone = normalize_timezone(offset_timezone)
              begin
                starting_time = Time.zone.parse("#{date} #{time}")
              rescue ArgumentError   # 'm/d/y' format on european comp
                m, d, y = date.split(/[\/\-]/)
                dt = [y, m, d].join('/')
                starting_time = Time.zone.parse("#{dt} #{time}")
              end
              category_data[category][:segment][segment][:starting_time] = starting_time
              dates << starting_time
            end
          }
        end

        data[:categories] = category_data
        data[:start_date] = dates.min
        data[:end_date] = dates.max
        return data
      end
      def parse_category_result(url)
        data = []
        begin
          page = @agent.get(url)
          #page.encoding = "utf-8"
        rescue Mechanize::ResponseCodeError => e
          case e.response_code
          when "404"
            return data
          end
        end
        if table = search_table_by_first_header(page, "FPl.")
          table.search("./tr").each {|tr|
            tds = tr.search("./td")
            next if tds.empty?

            hash = {
              ranking: tds[0].text.to_i,
              skater_name: tds[1].text,
              skater_nation: tds[2].text,
              points: tds[3].text.to_f
            }
            if tds.size == 6
              hash[:sp_ranking] = tds[4].text.to_i
              hash[:fs_ranking] = tds[5].text.to_i
            elsif tds.size == 5
              hash[:sp_ranking] = tds[4].text.to_i
            end
            data << hash
          }
        end
        return data
      end
    end
  end  ## class
end
Fisk8Viewer::CompetitionParser.register(:isu_generic, Fisk8Viewer::CompetitionSummaryParser::ISUGeneric)

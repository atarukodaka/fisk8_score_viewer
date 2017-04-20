# -*- coding: utf-8 -*-
require 'pdftotext'
require 'active_support/core_ext/time/zones'
require 'mechanize'
require 'uri'
require 'open-uri'

#require 'fisk8viewer/score_parser'

module Fisk8Viewer
  class CompetitionParser
    include Logger
    
    def initialize
      @agent = Mechanize.new
      @nbsp = Nokogiri::HTML.parse("&nbsp;").text
    end

    def parse(url)
      logger.debug  "  parsing #{url}..."
      res = parse_summary(url)
      #score_parser = Fisk8Viewer::ScoreParser.new
      #scores = []
      res[:categories].each do |c, v|
        #["Men", "Ladies"].each do |c|
        v[:segment].each do |s, hash|
          #["Short Program", "Free Skating"].each do |s|
          #score_url = res[:categories][c][:segment][s][:score_url]
          score_url = hash[:score_url]
=begin          
          score_text = retrieve(score_url, dir: "pdf")
          opts = {
            #date: res[:categories][c][:segment][s][:starting_time],
            date: hash[:starting_time],
            result_pdf: score_url,
          }
          scores << score_parser.parse(score_text, opts)
=end
        end
      end

      ## type
      res[:competition_type] = 
        if res[:name] =~ /^ISU GP/ || res[:name] =~ /^ISU Grand Prix/
          :gp
        elsif res[:name] =~ /Olympic/
          :olympic
        elsif res[:name] =~ /^ISU World Figure/
          :world
        elsif res[:name] =~ /^ISU Four Continents/
          :fc
        elsif res[:name] =~ /^ISU European/
          :europe
        elsif res[:name] =~ /^ISU World Junior/
          :jworld
        else
          :unknown
        end
      
      ## abbr
      uri = URI.parse(url)
      res[:abbr] = uri.path.split('/').last

      ## season
      year, month = res[:start_date].year, res[:start_date].month
      year -= 1 if month <= 6
      res[:season] = "%04d-%02d" % [year, (year+1) % 100]
      
      ## return hash
      #res[:scores] = scores.flatten
      #{competition: res, scores: scores.flatten}
      res
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
      dates = []
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
=begin  
    ################
    def parse_segment_result(result_url)
      data = []
      page = @agent.get(result_url)
      table = search_table_by_first_header(page, "   Pl.  ")
      return data if table.nil?

      table.search("./tr").each {|tr|
        tds = tr.search("./td")
        next if tds.empty?

        skater_isu_number = 0
        if !(a = tds[1].search("a")).empty?
          bio_url = a.attribute("href").try(:value)
          if !bio_url.nil? && bio_url.match("http://www.isuresults.com/bios/isufs([0-9]+)\.htm")
            skater_isu_number = $1.to_i
          end
        end
        ranking = tds[0].text
        data << {
          ranking: ranking,
          skater_name: tds[1].text,
          skater_nation: tds[2].text,
          skater_isu_number: skater_isu_number,
          tss: tds[3].text,
          tes: tds[4].text,
          pcs: tds[6].text,
          components_ss: tds[7].text,
          components_tr: tds[8].text,
          components_pe: tds[9].text,
          components_ch: tds[10].text,
          components_in: tds[11].text,
          deductions: tds[12].text,
          starting_number: tds[13].text.gsub("#", "").gsub(" ", "")
        }
      }
      return data
    end
    ################
    def parse_skating_order(url)
      data = []
      group_num = 1
      page = @agent.get(url)
      if table = search_table_by_first_header(page, "StN.")
        table.search("./tr").each {|tr|
          tds = tr.search("./td")
          next if tds.empty?

          text0 = tds[0].text.gsub(@nbsp, " ")
          if (text0 =~ /^\s*$/) && (tds[1].text =~ /Warm\-Up Group ([0-9]+)/)
            group_num = $1.to_i
          else
            starting_number = tds[0].text
            name = tds[1].text
            nation = tds[2].text
            data << {starting_number: starting_number, skater_name: name, skater_nation: nation, group: group_num}
          end
        }
        return data
      end
    end
    ################
    def parse_category_entry(url)
      data = []
      page = @agent.get(url)
      if table = search_table_by_first_header(page, "No.")
        table.search("./tr").each {|tr|
          tds = tr.search("./td")
          next if tds.empty?

          number = tds[0].text
          name = tds[1].text
          nation = tds[2].text
          data << {number: number, skater_name: name}
        }
      end
      return data
    end
=end
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
  end  ## class
end

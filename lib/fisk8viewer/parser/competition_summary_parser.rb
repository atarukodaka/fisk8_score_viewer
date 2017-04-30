require 'fisk8viewer/utils'

module Fisk8Viewer
  class Parser
    module CompetitionSummaryParser
      include Scraper
      include Utils

      def parse_datetime(str)
        begin
          tm = Time.zone.parse(str)
        rescue ArgumentError
          raise "invalid date format. use :isu_generic_mdy as parser"
        end
      end
      def parse_city_country(page)
        str = page.search("td.caption3").first.text
        str =~ %r{^(.*) *[,/] ([A-Z][A-Z][A-Z]) *$};
        city, country = $1, $2
        [city.sub(/ *$/, ''), country]
      end
      def parse_summary_table(page, url: "")
        ## summary table
        category_elem = page.xpath("//*[text()='Category']").first
        #rows = category_elem.xpath("../../tr")
        rows = category_elem.ancestors.xpath("table").first.xpath("tr")

        category = ""
        summary = []
        rows.map do |row|
          next if row.xpath("td").blank?

          if c = row.xpath("td[1]").text.presence
            category = c.upcase
          end
          segment = (elem = row.xpath("td[2]")) ? elem.text.upcase : ""

          next if category.blank? && segment.blank?
          
          result_url = (elem = row.xpath("td[4]/a/@href").presence) ? URI.join(url, elem.text): ""
          score_url = (elem = row.xpath("td[5]/a/@href").presence) ? URI.join(url, elem.text): ""
          #result_url = row.xpath("td[4]/a/@href").presence
          #score_url = row.xpath("td[5]/a/@href").presence

          summary << {
            category: category, 
            segment: segment,
            result_url: result_url.to_s,
            score_url: score_url.to_s,
          }
        end
        summary
      end

      def parse_time_schedule(page)
        ## time schdule
        Time.zone = "UTC"
        date_elem = page/"//*[text()='Date']"
        rows = date_elem/"../../tr"
        dt_str = ""
        time_schedule = []
        rows.each do |row|
          next if row.xpath("td").blank?
          if t = row.xpath("td[1]").text.presence
            dt_str = t
            next
          end
          tm_str = row.xpath("td[2]").text
          tm = parse_datetime("#{dt_str} #{tm_str}")
          
          time_schedule << {
            time: tm,
            category: row.xpath("td[3]").text.upcase,
            segment: row.xpath("td[4]").text.upcase,
          }
        end
        time_schedule
      end
      ################
      def parse_competition_summary(url)
        @agent ||= Mechanize.new
        page = get_url(url)
        data = {}
        
        data[:name] = page.title
        data[:site_url] = url
        data[:city], data[:country] = parse_city_country(page)

        data[:result_summary] = parse_summary_table(page, url: url)
        data[:time_schedule] = parse_time_schedule(page)
        data
      end
      ################
    end
  end  ## module
end

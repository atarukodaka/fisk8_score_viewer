require 'fisk8viewer/utils'

module Fisk8Viewer
  class Parser
    class CompetitionSummaryParser
      include Utils

      def parse_datetime(str)
        begin
          Time.zone ||= "UTC"
          tm = Time.zone.parse(str)
        rescue ArgumentError
          raise "invalid date format"
        end
      end
      def parse_city_country(page)
        str = page.search("td.caption3").first.text
        str =~ %r{^(.*) *[,/] ([A-Z][A-Z][A-Z]) *$};
        city, country = $1, $2
        [city.sub(/ *$/, ''), country]
      end
      def parse_summary_table(page, url: "")
        category_elem = page.xpath("//*[text()='Category']").first
        rows = category_elem.ancestors.xpath("table").first.xpath("tr")

        category = ""
        summary = []
        
        rows.each do |row|
          next if row.xpath("td").blank?
          
          if c = row.xpath("td[1]").text.presence
            category = c.upcase
          end
          segment = row.xpath("td[2]").text.upcase
          next if category.blank? && segment.blank?
          
          result_url = row.xpath("td[4]/a/@href").text
          score_url = row.xpath("td[5]/a/@href").text

          summary << {
            category: category,
            segment: segment,
            result_url: (result_url.present?) ? URI.join(@url, result_url).to_s: "",
            score_url: (score_url.present?) ? URI.join(@url, score_url).to_s : "",
          }
        end
        summary
      end

      def parse_time_schedule(page)
        ## time schdule
        date_elem = page.xpath("//*[text()='Date']").first
        rows = date_elem.xpath("../../tr")
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
          next if tm.nil?
          
          time_schedule << {
            time: tm,
            category: row.xpath("td[3]").text.upcase,
            segment: row.xpath("td[4]").text.upcase,
          }
        end
        time_schedule
      end
      def parse_name(page)
        page.title
      end
      ################
      def parse(url)
        @url = url
        page = get_url(url)
        city, country = parse_city_country(page)
        
        data = {
          name: parse_name(page),
          site_url: url,
          city: city,
          country: country,
          result_summary: parse_summary_table(page),
          time_schedule: parse_time_schedule(page),
        }
      end
      ################
    end
  end  ## module
end

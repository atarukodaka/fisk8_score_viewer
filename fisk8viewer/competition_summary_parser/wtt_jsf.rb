require 'fisk8viewer/competition_summary_parser'

module Fisk8Viewer
  module CompetitionSummaryParser
    class WTT_JSF < Base
      def parse_summary(url)
        page = @agent.get(url)
        data = {}

        data[:name] = page.title
=begin
        city_country = page.xpath("//td[contains(text(), '/')]").first.text
        data[:city], data[:country] = city_country.split(/ *\/ */)
=end
        data[:site_url] = url
        ## summary table
        header_elem = page.xpath("//*[text()='Teams']").first
        rows = header_elem.xpath("../../tr")
        category = ""
        segment = ""
        summary = []
        rows.each do |row|
          next if row.xpath("td").blank?

          if row.xpath("td[2]").text == 'Entries'
            category = row.xpath("td[1]").text.upcase
          elsif row.xpath("td").count == 2
            segment = row.xpath("td[1]").text.upcase
          elsif row.xpath("td[1]").text == "Judges Score (pdf)"
            score_url = URI.join(url, row.xpath("td[1]/a/@href").text).to_s
            summary << {
              category: category, 
              segment: segment,
              result_url: "",
              score_url: score_url,
            }
          end
        end
        data[:result_summary] = summary

        ## time schdule
        Time.zone = "UTC"
        date_elem = page/"//*[text()='Date']"
        rows = date_elem/"../../tr"
        dt_str = ""
        time_schedule = []

        rows.each do |row|
          next if row.xpath("td").blank?

          tds = row.xpath("td")
          if tds.count == 4
            dt_str = tds[0].text
            tds.pop
          end
          tm_str, category, segment = tds
          tm = Time.zone.parse("#{dt_str} #{tm_str.text}")
          next if tm.nil?
          
          time_schedule << {
            time: tm,
            category: category.text.upcase,
            segment: segment.text.upcase,
          }
        end
        binding.pry
        data[:time_schedule] = time_schedule
        data
      end

      ## register
      Fisk8Viewer::CompetitionSummaryParser.register(:wtt_jsf, self)
    end ## class

    ################
    class WTT_2017 < WTT_JSF
      def parse_summary(url)
        data = super(url)
        data[:name] = "ISU World Team Trophy 2017"
        data[:city] = "Tokyo"
        data[:country] = "JPN"

        data
      end
      ## register
      Fisk8Viewer::CompetitionSummaryParser.register(:wtt_2017, self)
    end ## class
  
  end
end


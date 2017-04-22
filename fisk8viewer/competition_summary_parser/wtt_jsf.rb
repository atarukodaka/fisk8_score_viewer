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
        ## fxxing sxxt HTML....TD has no TR parents...gave up to parse
        data[:time_schedule] = []
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

        Time.zone = "UTC"
        data[:time_schedule] =
          [
           {
             time: Time.zone.parse("2017/04/20 15:15:00"),
             category: "ICE DANCE",
             segment: "SHORT DANCE",
           },
           {
             time: Time.zone.parse("2017/04/20 16:35:00"),
             category: "LADIES",
             segment: "SHORT PROGRAM",
           },
           {
             time: Time.zone.parse("2017/04/20 18:40:00"),
             category: "MEN",
             segment: "SHORT PROGRAM",
           },
           {
             time: Time.zone.parse("2017/04/21 16:00:00"),
             category: "PAIRS",
             segment: "SHORT PROGRAM",
           },
           {
             time: Time.zone.parse("2017/04/21 17:25:00"),
             category: "ICE DANCE",
             segment: "FREE DANCE",
           },
           {
             time: Time.zone.parse("2017/04/21 19:00:00"),
             category: "MEN",
             segment: "FREE SKATING",
           },
           {
             time: Time.zone.parse("2017/04/22 15:15:00"),
             category: "PAIRS",
             segment: "FREE SKATING",
           },
           
           {
             time: Time.zone.parse("2017/04/22 16:50:00"),
             category: "LADIES",
             segment: "FREE SKATING",
           },
          ]
        data
      end
      ## register
      Fisk8Viewer::CompetitionSummaryParser.register(:wtt_2017, self)
    end ## class
  
  end
end


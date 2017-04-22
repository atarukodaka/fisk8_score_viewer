require 'fisk8viewer/competition_summary_parser'

module Fisk8Viewer
  module CompetitionSummaryParser
    class ISU_Generic < Base
      def parse_summary(url)
        page = @agent.get(url)
        data = {}

        data[:name] = page.title
        
        city_country = page.xpath("//td[contains(text(), '/')]").presence ||
          page.xpath("//td[contains(text(), ',')]")

        data[:city], data[:country] = city_country.first.text.split(/ *\/ */)
        data[:site_url] = url
        
        ## summary table
        category_elem = page.xpath("//*[text()='Category']").first
        rows = category_elem.xpath("../../tr")
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
          summary << {
            category: category, 
            segment: segment,
            result_url: result_url.to_s,
            score_url: score_url.to_s,
          }
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
          if t = row.xpath("td[1]").text.presence
            dt_str = t
            next
          end
          tm_str = row.xpath("td[2]").text

          time_schedule << {
            time: Time.zone.parse("#{dt_str} #{tm_str}"),
            category: row.xpath("td[3]").text.upcase,
            segment: row.xpath("td[4]").text.upcase,
          }
        end
        data[:time_schedule] = time_schedule
        data
      end
      ################
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
        fpi = page.xpath("//th[contains(text(), 'FPl.')]")
        return {} if fpi.blank?
        rows = fpi.first.xpath("../../tr")
        rows.each do |row|
          tds = row.xpath("td")
          next if tds.blank?
          
          hash = {
            rank: tds[0].text.to_i,
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
        end
        return data
      end

      ## register
      Fisk8Viewer::CompetitionSummaryParser.register(:isu_generic, self)
    end  ## class
  end
end



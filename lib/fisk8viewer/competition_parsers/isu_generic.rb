require 'fisk8viewer/competition_parsers/base'

module Fisk8Viewer
  module CompetitionParser
    class ISU_Generic < Base
      def parse_datetime(str)
        tm = Time.zone.parse(str)
      end
      def parse_city_country(page)
        str = page.search("td.caption3").first.text
        str =~ %r{^(.*) *[,/] ([A-Z][A-Z][A-Z]) *$};
        city, country = $1, $2
        [city.sub(/ *$/, ''), country]
      end
      def parse_summary(url)
        page = @agent.get(url)
        data = {}

        data[:name] = page.title
        data[:site_url] = url
        data[:city], data[:country] = parse_city_country(page)
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
          tm = parse_datetime("#{dt_str} #{tm_str}")

          time_schedule << {
            time: tm,
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
          page.encoding = 'iso-8859-1'  # for umlaut support
        rescue Mechanize::ResponseCodeError => e
          case e.response_code
          when "404"
            return data
          end
        end
        category = page.xpath("//table/tr/td")[2].text.upcase
        fpl = page.xpath("//th[contains(text(), 'FPl.')]")
        return {} if fpl.blank?
        rows = fpl.first.xpath("../../tr")
        rows.each do |row|
          tds = row.xpath("td")
          next if tds.blank?
          
          hash = {
            rank: tds[0].text.to_i,
            skater_name: tds[1].text.gsub(/  */, ' '),
            nation: tds[2].text,
            category: category,
            points: tds[3].text.to_f
          }
          if tds.size >= 6
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
      Fisk8Viewer::CompetitionParsers.register(:isu_generic, self)
    end  ## class
  end
end


################################################################

module Fisk8Viewer
  module CompetitionParser
    class ISU_Generic_mdy < ISU_Generic
      def parse_datetime(str)
        dt_str, tm_str = str.split(/ /)
        m, d, y = dt_str.split(/[,\/]/)
        dt_str = "%s/%s/%s" % [d, m, y]
        Time.zone.parse("#{dt_str} #{tm_str}")
      end
      Fisk8Viewer::CompetitionParsers.register(:isu_generic_mdy, self)
    end
  end
end

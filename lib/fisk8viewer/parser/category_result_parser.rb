
require 'fisk8viewer/utils'

module Fisk8Viewer
  class Parser
    module CategoryResultParser
      include Fisk8Viewer::Utils
      include Scraper

      def parse_category_result(url)
        data = []
        page = get_url(url)
        page.encoding = 'iso-8859-1'  # for umlaut support
        category = page.xpath("//table/tr/td")[2].text.upcase
        fpl = page.xpath("//th[contains(text(), 'FPl.')]")
        return {} if fpl.blank?
        rows = fpl.first.xpath("../../tr")
        rows.each do |row|
          tds = row.xpath("td")
          next if tds.blank?

          href = tds[1].xpath("a").first.attributes["href"].value
          href =~ /([0-9]+)\.htm$/
          isu_number = $1.to_i
          hash = {
            rank: tds[0].text.to_i,
            skater_name: normalize_skater_name(tds[1].text.gsub(/  */, ' ')),
            isu_number: isu_number,
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
    end  # module
  end
end

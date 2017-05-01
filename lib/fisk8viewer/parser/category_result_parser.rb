
require 'fisk8viewer/utils'

module Fisk8Viewer
  class Parser
    class CategoryResultParser
      include Fisk8Viewer::Utils

      def get_rows(page)
        fpl = page.xpath("//th[contains(text(), 'FPl.')]")
        return [] if fpl.blank?

        fpl.first.xpath("../../tr")
      end
      def get_category(page)
        page.xpath("//table/tr/td")[2].text.upcase
      end
      def parse(url)
        data = []
        page = get_url(url)
        page.encoding = 'iso-8859-1'  # for umlaut support
        category = get_category(page)
        
        rows = get_rows(page)
        rows[1..-1].each do |row|
          tds = row.xpath("td")
          next if tds.blank?
          
          href = row.xpath("td[2]/a/@href").text
          href =~ /([0-9]+)\.htm$/
          isu_number = $1.to_i

          # skater_name
          skater_name = normalize_skater_name(row.xpath("td[2]/a/text()").map(&:text).join(' / ').gsub(/  */, ' '))
          # nation
          tds[2].text =~ /([A-Z][A-Z][A-Z])/
          nation = $1
          hash = {
            rank: tds[0].text.to_i,
            skater_name: skater_name,
            isu_number: isu_number,
            nation: nation,
            category: category,
            points: row.xpath("td[4]").text.to_f
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

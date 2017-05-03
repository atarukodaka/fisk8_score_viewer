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

      def parse_isu_number(row)
        href = row.xpath("td[2]/a/@href").text
        href =~ /([0-9]+)\.htm$/
        $1.to_i
      end
      def parse_skater_name(row)
        #normalize_skater_name(row.xpath("td[2]").text)
        row.xpath("td[2]").text
      end
      def parse_nation(row)
        row.xpath("td[3]").text =~ /([A-Z][A-Z][A-Z])/
        $1
      end
      def parse_rankings(row)
        size = row.xpath("td").size
        if size >= 6
          [row.xpath("td[5]").text.to_i, row.xpath("td[6]").text.to_i]
        elsif size == 5
          [row.xpath("td[5]").text.to_i, nil]
        else
          [nil, nil]
        end
      end
      def parse_row(row)
        return {} if row.xpath("td").blank?
        sp_ranking, fs_ranking = parse_rankings(row)

        {
          rank: row.xpath("td[1]").text.to_i,
          skater_name: parse_skater_name(row),
          isu_number: parse_isu_number(row),
          nation: parse_nation(row),
          points: row.xpath("td[4]").text.to_f,
          sp_ranking: sp_ranking,
          fs_ranking: fs_ranking,          
        }
      end
      
      def parse(url)
        data = []
        page = get_url(url)
        page.encoding = 'iso-8859-1'  # for umlaut support
        category = get_category(page)

        rows = get_rows(page)
        rows[1..-1].map do |row|
          parse_row(row).merge(category: category)
        end
      end
    end  # module
  end
end

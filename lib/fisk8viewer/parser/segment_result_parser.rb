require 'fisk8viewer/utils'

module Fisk8Viewer
  class Parser
    class SegmentResultParser
      include Fisk8Viewer::Utils
      
      def initialize
        @headers = {}
      end
      def get_rows(page)
        fpl = page.xpath("//th[contains(text(), 'Pl.')]")
        return [] if fpl.blank?

        fpl.first.xpath("../../tr")
      end
      def get_category(page)
        page.search("tr.caption2").text.split(/ \- /).first.upcase
      end

      def get_segment(page)
        page.search("tr.caption2").text.split(/ \- /).last.upcase
      end

      def parse_rank(row)
        row.xpath("td[#{@headers[:rank]}]").text.to_i
      end
      def parse_isu_number(row)
        href = row.xpath("td[#{@headers[:skater_name]}]/a/@href").text
        href =~ /([0-9]+)\.htm$/
        $1.to_i
      end
      def parse_skater_name(row)
        normalize_skater_name(row.xpath("td[#{@headers[:skater_name]}]").text)
      end
      def parse_nation(row)
        row.xpath("td[#{@headers[:nation]}]").text =~ /([A-Z][A-Z][A-Z])/
        $1
      end
      def parse_row(row)
        return {} if row.xpath("td").blank?

        {
          rank: parse_rank(row),
          skater_name: parse_skater_name(row),
          isu_number: parse_isu_number(row),
          nation: parse_nation(row),
        }
      end
      
      def parse_table_header(row)
        row.xpath("th").each_with_index do |cell, i|
          case cell.text
          when /Pl./
            @headers[:rank] = i + 1
          when /Name/
            @headers[:skater_name] = i + 1
          when /Nation/
            @headers[:nation] = i + 1
          end
        end
      end
      def parse(url)
        data = []
        page = get_url(url)
        page.encoding = 'iso-8859-1'  # for umlaut support
        category = get_category(page)
        segment = get_segment(page)
        
        rows = get_rows(page)
        parse_table_header(rows[0])
        rows[1..-1].map do |row|
          parse_row(row).merge(category: category, segment: segment)
        end
      end
    end  # module
  end
end

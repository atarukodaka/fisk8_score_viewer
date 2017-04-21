module Fisk8Viewer
  module CompetitionSummaryParser
    class ISUGeneric
      def initialize
        @agent = Mechanize.new
      end
      def parse_summary(url, offset_timezone="UTC")
        page = @agent.get(url)
        data = {}

        data[:name] = page.title
        city_country = page.search("td.caption3").first.inner_text
        data[:city], data[:country] = city_country.split(/ *\/ */)
        data[:isu_site] = url
        
        ## summary table
        category_elem = page.xpath("//*[text()='Category']").first
        rows = category_elem.xpath("../../tr")
        category = 
        summary_table = rows.map do |row|
          tds = row.xpath("td")
          if cat_elem = row.xpath("td[1]")
            category = cat_elem.text
          end
          result_url = (elem = row.xpath("td[4]/a/@href").presence) ? URI.join(url, elem.text): ""
          score_url = (elem = row.xpath("td[5]/a/@href").presence) ? URI.join(url, elem.text): ""
          {
            category: category, 
            segment: row.xpath("td[2]").try(:text),
            result_url: result_url.to_s,
            score_url: score_url.to_s,
          }
        end
        binding.pry

        ## time schdule
        puts :foo
      end
    end  ## class
  end
end


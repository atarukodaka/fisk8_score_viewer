require 'mechanize'

module Fisk8Viewer
  class ISU_Bio
  #  class SkaterParser
    include Fisk8Viewer::Utils

    URLS = {
      MEN: "http://www.isuresults.com/bios/fsbiosmen.htm",
      LADIES: "http://www.isuresults.com/bios/fsbiosladies.htm",
      PAIRS: "http://www.isuresults.com/bios/fsbiospairs.htm",
      :"ICE DANCE" => "http://www.isuresults.com/bios/fsbiosicedancing.htm",
    }
    def parse_isu_summary(categories = nil)
      categories ||= URLS.keys
      @agent ||= Mechanize.new
      nation = ""
      records = []
      categories.each do |category|
        url = URLS[category]
        logger.debug("scrape #{category} on #{url}")
        page = @agent.get(url)
        page.xpath("//table[1]/tr").each do |row|
          ntn = row.xpath("td[1]").text
          nation = ntn if ntn.present?
          name = row.xpath("td[3]").text
          row.xpath("td[3]/a/@href").text =~ /(\d+)\.htm$/
          isu_number = $1.to_i
          records << {isu_number: isu_number, nation: nation, name: name, category: category}
        end
      end
      records
    end
=begin    
    def scrape_isu_numbers
      @agent ||= Mechanize.new

      hash = {}
      URLS.each do |category, url|
        logger.debug("scrape #{category} on #{url}")
        page = @agent.get(url)
        page.search("table//a").map do |link|
          link[:href] =~ /(\d+)\.htm/
          isu_number = $1.to_i
          skater_name = link.text
          
          hash[skater_name] = {isu_number: isu_number, category: category}
        end
      end
      hash
    end

    def scrape_skater(isu_number, category)
      url = isu_bio_url(isu_number)
      @agent ||= Mechanize.new

      begin
        page = @agent.get(url)
      rescue Mechanize::ResponseCodeError => e
        logger.warn("  #{url} not found")
        return {}
      end

      skater = {
        isu_number: isu_number,
        isu_bio:  url,
        category: category.to_s,
      }
      scraped_info = {
        name: :cname, nation: :nation, birthday: :dob,
        height: :height, hobbies: :hobbies,
        club: :club_name, howmtown: :htometown,
        profession: :occupation, start_career: :start_carrer,
        coach: :media_information_coach,
        choreographer: :media_information_choreographer,
      }.map {|k, v|
        [k, page.search("#FormView1_person_#{v.to_s}Label").text]
      }.to_h
      skater.merge(scraped_info)
    end
=end
  end  ## class
end

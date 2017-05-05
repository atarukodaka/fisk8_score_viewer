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
    def parse_isu_bio_summary(categories = nil)
      categories ||= URLS.keys
      @agent ||= Mechanize.new
      nation = ""
      records = []
      categories.each do |category|
        url = URLS[category]
        next if url.blank?
        logger.debug("parse #{category} on #{url}")
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

    def parse_isu_bio_details(isu_number, category)
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
      parsed_info = {
        name: :cname, nation: :nation, birthday: :dob,
        height: :height, hobbies: :hobbies,
        club: :club_name, howmtown: :htometown,
        profession: :occupation, start_career: :start_carrer,
        coach: :media_information_coach,
        choreographer: :media_information_choreographer,
      }.map {|k, v|
        [k, page.search("#FormView1_person_#{v.to_s}Label").text]
      }.to_h
      skater.merge(parsed_info)
    end
  end  ## class
end

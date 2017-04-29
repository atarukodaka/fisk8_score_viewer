require 'mechanize'
require 'pry-byebug'
require 'fisk8viewer'

module Fisk8Viewer
  class SkaterParser
    include Fisk8Viewer::Logger

    URLS = {
      MEN: "http://www.isuresults.com/bios/fsbiosmen.htm",
      LADIES: "http://www.isuresults.com/bios/fsbiosladies.htm",
      PAIRS: "http://www.isuresults.com/bios/fsbiospairs.htm",
      :"ICE DANCE" => "http://www.isuresults.com/bios/fsbiosicedancing.htm",
    }
    def scrape_isu_numbers(category)
      url = URLS[category]
      logger.debug("scrape #{category} on #{url}")

      agent = Mechanize.new
      page = agent.get(url)
      page.search("table//a").map do |link|
        link[:href] =~ /(\d+)\.htm/
        isu_number = $1.to_i
        skater_name = link.text
        
        [skater_name, {isu_number: isu_number, category: category}]
      end.to_h
    end

    def parse_skater(isu_number, category)
      url = "http://www.isuresults.com/bios/isufs%08d.htm" % [isu_number]
      agent = Mechanize.new

      begin
        page = agent.get(url)
      rescue Mechanize::ResponseCodeError => e
        logger.debug("  #{url} not found")
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
  end  ## class
end
################################################################
if $0 == __FILE__
  parser = Fisk8Viewer::SkaterParser.new
  parser.scrape_isu_bio(:MEN)
end

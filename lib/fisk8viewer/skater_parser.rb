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
      hash = {}

      url = URLS[category]
      return {} if url.nil?
      
      logger.debug("scrape #{category} on #{url}")
      
      agent = Mechanize.new
      page = agent.get(url)
      links = page.search("table//a")
      
      links.each do |link|
        href = link[:href]
        href =~ /(\d+)\.htm/
        name = link.inner_text
        href =~ /(\d+)\.htm$/
        isu_number = $1.to_i
        
        hash[name] = isu_number
      end
      hash
    end

    def parse_skater(isu_number, category)
      url = "http://www.isuresults.com/bios/isufs%08d.htm" % [isu_number]
      agent = Mechanize.new
      page = agent.get(url)

      skater = {
        isu_number: isu_number,
        isu_bio:  url,
        category: category.to_s,
        name: page.search('#FormView1_person_cnameLabel').text,
        nation: page.search('#FormView1_person_nationLabel').text,
        birthday: page.search('#FormView1_person_dobLabel').text,
        height: page.search('#FormView1_person_heightLabel').text,
        hobbies: page.search('#FormView1_person_hobbiesLabel').text,
        club: page.search('#FormView1_person_club_nameLabel').text,
        hometown: page.search('#FormView1_person_htometownLabel').text,
        profession: page.search('#FormView1_person_occupationLabel').text, 
        start_career: page.search('#FormView1_person_start_careerLabel').text,
        coach: page.search('#FormView1_person_media_information_coachLabel').text,
        choreographer: page.search('#FormView1_person_media_information_choreographerLabel').text,
      }
    end
  end  ## class
end
################################################################
if $0 == __FILE__
  parser = Fisk8Viewer::SkaterParser.new
  parser.scrape_isu_bio(:MEN)
  #parser.parse_skaters(:MEN)
end

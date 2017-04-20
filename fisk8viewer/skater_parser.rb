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
        #skaters[name] = {name: name, category: category, isu_number: isu_number, url: URI.join(url, href).to_s}
      end
      hash
    end

    def parse_skater(isu_number, category)
      skater = {}
      agent = Mechanize.new
      url = "http://www.isuresults.com/bios/isufs%08d.htm" % [isu_number]
      page = agent.get(url)

      skater[:isu_number] = isu_number
      skater[:isu_bio] = url
      skater[:category] = category.to_s
      skater[:name] = page.search('#FormView1_person_cnameLabel').children.text
      skater[:nation] = page.search('#FormView1_person_nationLabel').children.text
      skater[:birthday] = page.search('#FormView1_person_dobLabel').children.text

      skater[:height] = page.search('#FormView1_person_heightLabel').children.text
      skater[:hobbies] = page.search('#FormView1_person_hobbiesLabel').children.text
      skater[:club] = page.search('#FormView1_person_club_nameLabel').children.text
      skater[:hometown] = page.search('#FormView1_person_htometownLabel').children.text
      skater[:profession] = page.search('#FormView1_person_occupationLabel').children.text
      skater[:start_career] = page.search('#FormView1_person_start_careerLabel').children.text

      skater[:coach] = page.search('#FormView1_person_media_information_coachLabel').children.text
      skater[:choreographer] = page.search('#FormView1_person_media_information_choreographerLabel').children.text

      skater
    end
  end  ## class
end
################################################################
if $0 == __FILE__
  parser = Fisk8Viewer::SkaterParser.new
  parser.scrape_isu_bio(:MEN)
  #parser.parse_skaters(:MEN)
end

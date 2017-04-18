require 'mechanize'
require 'pry-byebug'

module Fisk8Viewer
  class SkaterParser
    def scrape_isu_bio
      [:MEN, :LADIES].map do |category|
        scrape_isu_bio_by_category(category)
      end.flatten
    end
    def scrape_isu_bio_by_category(category)
    url = case category
            when :MEN
              "http://www.isuresults.com/bios/fsbiosmen.htm"
            when :LADIES
              "http://www.isuresults.com/bios/fsbiosladies.htm"
            else
              raise
            end
      agent = Mechanize.new
      page = agent.get(url)
      links = page.search("table//a")

      skaters = []
      links.each do |link|
        href = link[:href]
        href =~ /(\d+)\.htm/
        name = link.inner_text
        href =~ /(\d+)\.htm$/
        isu_number = $1.to_i

        skaters << {name: name, category: category, isu_number: isu_number, url: URI.join(url, href).to_s}
        #puts $1
        #skaters << parse_skater($1.to_i, category)
      end
      #binding.pry
      skaters
    end

    def parse_skater(isu_number, category)
      #skater = Skater.where(isu_number: isu_number).first || Skater.create(isu_number: isu_number)
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

      #skater.save
      p skater.inspect
      skater
    end
  end
end

if $0 == __FILE__
  parser = Fisk8Viewer::SkaterParser.new
  parser.scrape_isu_bio(:MEN)
  #parser.parse_skaters(:MEN)
end

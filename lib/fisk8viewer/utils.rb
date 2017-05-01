require 'pdftotext'
require 'open-uri'
require 'mechanize'

module Fisk8Viewer
  module Utils
   
    def logger
      @logger ||= ::Logger.new(STDERR, date_time_format: '%Y-%m-%d %H:%M')
    end

    def get_url(url)
      @agent ||= Mechanize.new
      @agent.get(url)
    end

    def convert_pdf(url, dir: "./")
      return "" if url.blank?

      ## create dir if not exists
      FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)

      ## convert pdf to text
      filename = File.join(dir, URI.parse(url).path.split('/').last)
      open(url) do |f|
        File.open(filename, "w") do |out|
          out.puts f.read
        end
      end
      Pdftotext.text(filename)
    end
    
    def normalize_skater_name(skater_name)
      skater_name.split(%r[ */ *]).map do |name|
        if name =~ /^([A-Z][A-Z][[:alpha:]]*) +(.*)$/ || name =~ /^(Mc[[:alpha:]]*) +(.*)$/
          last_name, first_name = $1, $2
          "#{first_name} #{last_name}"
        else
          name
        end
      end.join(" / ")
    end

    def isu_bio_url(isu_number)
      "http://www.isuresults.com/bios/isufs%08d.htm" % [isu_number.to_i]
    end
  end  ## module
end

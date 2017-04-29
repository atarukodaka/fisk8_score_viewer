require 'open-uri'
require 'pdftotext'

module Fisk8Viewer
  module Utils
   
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
        if name =~ /^([A-Z][A-Z][[:alpha:]]*) +(.*)$/
          last_name, first_name = $1, $2
          "#{first_name} #{last_name}"
        else
          name
        end
      end.join(" / ")
    end

    module_function :convert_pdf, :normalize_skater_name
  end  ## module
end

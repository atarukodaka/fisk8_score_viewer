module Fisk8Viewer
  VERSION = 1.0

  module Logger
    def logger
      if @logger.nil?
        @logger = ::Logger.new(STDERR)
        @logger.datetime_format = '%Y-%m-%d %H:%M'
      end
      @logger
    end
  end ## module

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
  end
end

require 'fisk8viewer/competition_parser'
require 'fisk8viewer/skater_parser'
require 'fisk8viewer/score_parser'
require 'fisk8viewer/updater'


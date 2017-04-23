module Fisk8Viewer
  module Logger
    def logger
      if @logger.nil?
        @logger = ::Logger.new(STDERR)
        @logger.datetime_format = '%Y-%m-%d %H:%M'
      end
      @logger
    end
  end ## module
end

module Fisk8Viewer
  module Parsers
    @registered = {}
    
    class << self
      attr_reader :registered
      def register(key, klass)
        @registered[key] = klass
      end
    end
  end
end

require 'fisk8viewer/parsers/isu_generic'
require 'fisk8viewer/parsers/isu_generic_mdy'
require 'fisk8viewer/parsers/wtt_2017'

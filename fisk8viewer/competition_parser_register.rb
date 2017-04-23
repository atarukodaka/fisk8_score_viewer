module Fisk8Viewer
  module CompetitionParserRegister
    @registered = {}
    
    class << self
      attr_reader :registered
      def register(key, klass)
        @registered[key] = klass
      end
    end
  end
end



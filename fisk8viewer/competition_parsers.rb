module Fisk8Viewer
  module CompetitionParsers
    @registered = {}
    
    class << self
      attr_reader :registered
      def register(key, klass)
        @registered[key] = klass
      end
    end
  end
end

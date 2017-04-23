module Fisk8Viewer
  class CompetitionAdaptor
    extend Forwardable
    def_delegators :@data, :[]
    attr_reader :data
    
    def initialize(parsed_hash)
      @data = parsed_hash  # .with_indifferent_access
    end
    
    def categories
      @categories ||= data[:result_summary].map {|h| h[:category]}.sort.uniq
    end
    def segments(category)
      data[:result_summary].select {|h| h[:category] == category && h[:segment].present?}.map {|h| h[:segment]}.uniq
    end
    ################
    def result_url(category)
      (hash = _select(:result_summary, category, "")) ? hash[:result_url] : ""
    end
    def score_url(category, segment)
      (hash = _select(:result_summary, category, segment)) ? hash[:score_url] : ""      
    end
    def starting_time(category, segment)
      (hash = _select(:time_schedule, category, segment)) ? hash[:score_url] : ""      
    end

    private
    def _select(key, category, segment)
      data[key].select {|h|
        h[:category] == category && h[:segment] == segment
      }.first
      
    end
  end
end


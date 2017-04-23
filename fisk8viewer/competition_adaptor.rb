module Fisk8Viewer
  class CompetitionAdaptor
    extend Forwardable
    def_delegators :@data, :[]
    attr_reader :data
    
    def initialize(parsed_hash)
      @data = parsed_hash  # .with_indifferent_access
      @data[:competition_type] = competition_type(@data[:name])

      ## dates
      @data[:start_date] = @data[:time_schedule].map {|e| e[:time]}.min
      @data[:end_date] = @data[:time_schedule].map {|e| e[:time]}.max

      ## season
      if @data[:start_date].present?
        year, month = @data[:start_date].year, @data[:start_date].month
        year -= 1 if month <= 6
        @data[:season] = "%04d-%02d" % [year, (year+1) % 100]
      end
    end
    
    ################
    def categories
      @categories ||= data[:result_summary].map {|h| h[:category]}.sort.uniq
    end
    def segments(category)
      data[:result_summary].select {|h| h[:category] == category && h[:segment].present?}.map {|h| h[:segment]}.uniq
    end
    def result_url(category)
      (hash = _select(:result_summary, category, "")) ? hash[:result_url] : ""
    end
    def score_url(category, segment)
      (hash = _select(:result_summary, category, segment)) ? hash[:score_url] : ""      
    end
    def starting_time(category, segment)
      (hash = _select(:time_schedule, category, segment)) ? hash[:time] : ""      
    end
    def method_missing(name, *args)
      @data.send(name, *args)
    end
    
    ################
    def competition_type(name)
      case name
      when /^ISU GP/, /^ISU Grand Prix/
        :gp
      when /Olympic/
        :olympic
      when /^ISU World Figure/
        :world
      when /^ISU Four Continents/
        :fc
      when /^ISU European/
        :europe
      when /^ISU World Team/
        :team
        
      when /^ISU World Junior/
        :jworld
      when /^ISU JGP/, /^ISU Junior Grand Prix/
        :jgp
      else
        :unknown
      end
    end

    ################
    private
    def _select(key, category, segment)
      data[key].select {|h|
        h[:category] == category && h[:segment] == segment
      }.first
      
    end
  end
end


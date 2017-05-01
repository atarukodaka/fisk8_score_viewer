module Fisk8Viewer
  class CompetitionSummaryAdaptor
    extend Forwardable
    def_delegators :@data, :[]
    attr_reader :data
    
    def initialize(parsed_hash)
      @data = parsed_hash  # .with_indifferent_access
      @data[:result_summary] ||= []
      @data[:time_schedule] ||= []      

      ## dates
      @data[:start_date] = @data[:time_schedule].map {|e| e[:time]}.min
      @data[:end_date] = @data[:time_schedule].map {|e| e[:time]}.max
        
      # add year name unless it contains any year info
      @data[:name] = @data[:name].to_s + " #{@data[:start_date].try(:year)}" unless @data[:name] =~ /[0-9][0-9][0-9][0-9]/
      
      ## type, short_name
      @data[:competition_type] = competition_type
      @data[:short_name] = short_name

      ## season
      if @data[:start_date].present?
        year, month = @data[:start_date].year, @data[:start_date].month
        year -= 1 if month <= 6
        @data[:season] = "%04d-%02d" % [year, (year+1) % 100]
      end

      @_categories = nil; @_segments = {}; @_result_url = {}
      @_score_url = Hash.new { |h,k| h[k] = {} }
      @_starting_time = Hash.new { |h,k| h[k] = {} }      
    end
    
    ################
    def categories
      @_categories ||= data[:result_summary].map {|h| h[:category]}.sort.uniq
    end
    def segments(category)
      @_segments[category] ||= data[:result_summary].select {|h| h[:category] == category && h[:segment].present?}.map {|h| h[:segment]}.uniq
    end
    def result_url(category)
      @_result_url[category] ||= (hash = _select(:result_summary, category, "")) ? hash[:result_url] : ""
    end
    def score_url(category, segment)
      @_score_url[category][segment] ||= (hash = _select(:result_summary, category, segment)) ? hash[:score_url] : ""      
    end
    def starting_time(category, segment)
      @_starting_time[category][segment] ||= (hash = _select(:time_schedule, category, segment)) ? hash[:time] : ""      
    end
    def method_missing(name, *args)
      @data.send(name, *args)
    end
    
    ################
    def competition_type
      case @data[:name]
      when /^ISU GP/, /^ISU Grand Prix/
        :gp
      when /Olympic/
        :olympic
      when /^ISU World Figure/, /^ISU World Championships/
        :world
      when /^ISU Four Continents/
        :fcc
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
    def short_name
      year = @data[:start_date].try(:year)
      city = @data[:city]
      country = @data[:country]
      
      @_short_name =
        case @data[:competition_type]
        when :olympic
          "ISU OLYMPIC #{year}"
        when :gp
          if @data[:name] =~ /Final/
            "ISU GPF #{year}"
          else
            "ISU GP #{country} #{year}"
          end
        when :world
          "ISU WORLD #{year}"
        when :fcc
          "ISU 4CC #{year}"
        when :europe
          "ISU EURO #{year}"
        when :team
          "ISU TEAM #{year}"
        when :jworld
          "ISU WORLD J #{year}"
        when :jgp
          "ISU WORLD J #{year}"
        else
          @data[:name]
        end
    end

    ################

    def _select(key, category, segment)
      data[key].select {|h|
        h[:category] == category && h[:segment] == segment
      }.first
      
    end
  end
end


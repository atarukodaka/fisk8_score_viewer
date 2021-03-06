module Fisk8Viewer
  class CompetitionSummary
    extend Forwardable
    def_delegators :@data, :[]
    attr_reader :data
    
    def initialize(parsed_hash)
      @data = parsed_hash
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

=begin
      @_categories = nil; @_segments = {};
      @_result_url = Hash.new { |h,k| h[k] = {} }
      @_score_url = Hash.new { |h,k| h[k] = {} }
      @_starting_time = Hash.new { |h,k| h[k] = {} }      
=end
    end
    
    ################
    def categories
      data[:result_summary].map {|h| h[:category]}.sort.uniq
    end
    def segments(category)
      data[:result_summary].select {|h| h[:category] == category && h[:segment].present?}.map {|h| h[:segment]}.uniq
    end
    def result_url(category, segment=nil)
      if segment.nil?
        find_row(:result_summary, category, "")[:result_url]
      else
        find_row(:result_summary, category, segment)[:result_url]
      end
    end
    def score_url(category, segment)
      find_row(:result_summary, category, segment)[:score_url]
    end
    def starting_time(category, segment)
      find_row(:time_schedule, category, segment)[:time]
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
          "ISU_OLYMPIC_#{year}"
        when :gp
          if @data[:name] =~ /Final/
            "ISU_GPF_#{year}"
          else
            "ISU_GP_#{country} #{year}"
          end
        when :world
          "ISU_WORLD_#{year}"
        when :fcc
          "ISU_4CC_#{year}"
        when :europe
          "ISU_EURO_#{year}"
        when :team
          "ISU_TEAM_#{year}"
        when :jworld
          "ISU_WORLD_J_#{year}"
        when :jgp
          "ISU_WORLD_J_#{year}"
        else
          @data[:name].gsub(/Figure Skating */, '').gsub(/\s/, '_')
        end
    end

    ################
    private
    def find_row(key, category, segment)
      data[key].select {|h|
        h[:category] == category && h[:segment] == segment
      }.first
      
    end
  end
end


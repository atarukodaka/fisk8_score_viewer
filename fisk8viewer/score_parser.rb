module Fisk8Viewer
  class ScoreParser
    def init_status
      {
        mode: :competition,
        #score: {technicals: [], components: []},
        competition_name: nil,
        category: nil,
        segment: nil,
        component_number: 1,
      }
    end
    def parse(text, opts={})
      scores = []
      score = {technicals: [], components: []}
      status = init_status()
      
      text.split("\n").each do |line|
        line.gsub!(/ +/, ' ')
        line.gsub!(/^ */, '')
        line.chomp!
        next if line =~ /^ *$/
        
        case status[:mode]
        when :competition
          if status[:competition_name].nil?
            status[:competition_name] = line
            next
          elsif line =~ /^([A-Z]+) ([A-Z ]+) JUDGES DETAILS PER SKATER$/
            status[:category] = $1
            status[:segment] = $2
            status[:mode] = :skater
          end
        when :skater
          if line =~ /^ *([0-9]+) ([[:alpha:]\- ]+) ([0-9]+) ([0-9\.]+) ([0-9\.]+) ([0-9\.]+) ([0-9\.\-]+)/
            score = {
              rank: $1, starting_number: $3.to_i, tss: $4,tes: $5, pcs: $6,
              deductions: $7.to_i.abs * -1,
              technicals: [], components: [],
            }
            $2 =~ /(.*) ([A-Z]+)$/
            score.merge!({ skater_name: $1, nation: $2})
          elsif line =~ /^ *Elements Value/
            status[:mode] = :tes
            next
          end
        when :tes
          if line =~ /^ *Program Components/
            status[:mode] = :pcs
            next
          end
          if line =~ / *([0-9]+) ([0-9A-Za-z\+\!<\*]+) ([<\!\*]*) *([0-9\.]+) (x?) *([0-9\.\-]+) ([0-9\- ]+) ([0-9\.\-]+)$/
            tech = {
              number: $1.to_i, element: $2, info: $3, base_value: $4,
              credit: $5, goe: $6, judges: $7, value: $8,
            }
            score[:technicals] << tech
          end
        when :pcs
          if line =~ /^ *Starting/
            score[:competition_name] = status[:competition_name]
            score[:category] = status[:category]
            score[:segment] = status[:segment]
            if opts[:date]
              score[:date] = opts[:date]
            end
            if opts[:result_pdf]
              score[:result_pdf] = opts[:result_pdf]
            end
            scores << score
            score = {technicals: [], components: []}
            status[:component_number] = 1
            status[:mode] = :skater
            next
          end
          if line =~ / *([A-Za-z\s]+) ([0-9\.]+) ([0-9\. ]+) ([0-9\.]+)$/
            comp = {
              component: $1, factor: $2, judges: $3, value: $4, number: status[:component_number],
            }
            score[:components] << comp
            status[:component_number] += 1
          end
        end
      end

      ## TODO: refactoring
      score[:competition_name] = status[:competition_name]
      score[:category] = status[:category]
      score[:segment] = status[:segment]
      if opts[:date]
        score[:date] = opts[:date]
      end
      if opts[:result_pdf]
        score[:result_pdf] = opts[:result_pdf]
      end

      scores << score
      return scores
    end  ## def
  end
end

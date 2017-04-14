module Fisk8Viewer
  class ScoreParser
    def parse(text, opts={})
      scores = []
      #score = Score.new
      score = {technicals: [], components: []}
      competition_name = nil
      category = nil
      segment = nil
      component_number = 1
      mode = :competition

      text.split("\n").each do |line|
        line.gsub!(/ +/, ' ')
        line.chomp!
        line.gsub!(/^ */, '')
        next if line =~ /^ *$/
        
        case mode
        when :competition
          if competition_name.nil?
            competition_name = line
            next
          elsif line =~ /^([A-Z]+) ([A-Z ]+) JUDGES DETAILS PER SKATER$/
            category = $1
            segment = $2
            mode = :skater
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
            mode = :tes
            next
          end
        when :tes
          if line =~ /^ *Program Components/
            mode = :pcs
            next
          end
          if line =~ / *([0-9]+) ([0-9A-Za-z\+\!<\*]+) ([<\!\*]*) *([0-9\.]+) (x?) *([0-9\.\-]+) ([0-9\- ]+) ([0-9\.\-]+)$/
            tech = {
              number: $1.to_i, element: $2, info: $3, base_value: $4,
              credit: $5, goe: $6, judges: $7, value: $8,
            }
            score[:technicals] << tech
            #score.technicals << tech
          end
        when :pcs
          if line =~ /^ *Starting/
            score[:competition_name] = competition_name
            score[:category] = category
            score[:segment] = segment
            if opts[:date]
              score[:date] = opts[:date]
            end
            if opts[:result_pdf]
              score[:result_pdf] = opts[:result_pdf]
            end
            scores << score
            score = {technicals: [], components: []}
            component_number = 1
            mode = :skater
            next
          end
          if line =~ / *([A-Za-z\s]+) ([0-9\.]+) ([0-9\. ]+) ([0-9\.]+)$/
            comp = {
              component: $1, factor: $2, judges: $3, value: $4, number: component_number,
            }
            score[:components] << comp
            component_number += 1
          end
        end
      end
      return scores
    end
  end
end

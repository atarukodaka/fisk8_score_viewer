module Fisk8Viewer
  class ScoreParser
    def parse(text)
      text = text.force_encoding('UTF-8').gsub(/  +/, ' ').gsub(/^ */, '').gsub(/\n\n+/, "\n").chomp
      text_by_skaters = text.split(/ *Starting Total/)

      header = text_by_skaters.shift
      header =~ /^(.*)\n([A-Z\s]+) (SHORT|FREE) ([A-Z]+) JUDGES DETAILS PER SKATER/
      competition_name = $1
      category = $2
      segment = "#{$3} #{$4}"

      scores = []
      text_by_skaters.each do |t|
        mode = :skater
        score = {competition_name: competition_name, category: category, segment: segment,
          technicals: [], components: [],}
        t.split(/\n/).each do |line|
          case mode
          when :skater
            if line =~ /^([0-9]+) ([[:alpha:]\- \/']+) ([A-Z]+) ([0-9]+) ([0-9\.]+) ([0-9\.]+) ([0-9\.]+) ([0-9\.\-]+)/
              hash = {
                rank: $1.to_i, skater_name: $2, nation: $3, starting_number: $4.to_i,
                tss: $5.to_f, tes: $6.to_f, pcs: $7.to_f, deductions: $8.to_f,
              }
              score.merge!(hash)
              mode = :tes
            end
          when :tes
            if line =~ /^([0-9]+) ([0-9A-Za-z\+\!<\*]+) ([<\!\*]*) *([0-9\.]+) (x?) *([0-9\.\-]+) ([0-9\- ]+) ([0-9\.\-]+)$/
              score[:technicals] << {
                number: $1.to_i, element: $2, info: $3, base_value: $4.to_f,
                credit: $5, goe: $6.to_f, judges: $7, value: $8.to_f,
              }
            elsif line =~ /^Program Components/
              mode = :pcs
            end
          when :pcs
            if line =~ /^([A-Za-z\s\/]+) ([\d\.]+) ([\d\. ]+) ([\d\.]+)$/
              score[:components] << {
                component: $1, factor: $2.to_f, judges: $3, value: $4.to_f,
                number: (score[:components].size+1).to_i,
              }
            end
          end
        end  ## each line
        scores << score
      end  ## by skater
      scores
    end  # def parser
  end
end

require 'fisk8viewer/utils'

module Fisk8Viewer
  class ScoreParser
    include Utils
    
    def parse_score(text, additional_entries: {})
      mode = :skater
      score = { technicals: [], components: [],}.merge(additional_entries)

      text.split(/\n/).each do |line|
        case mode
        when :skater
          name_re = %q[[[:alpha:]\.\- \/\']+]
          if line =~ /^(\d+) (#{name_re}) ([A-Z]+) (\d+) ([\d\.]+) ([\d\.]+) ([\d\.]+) ([\d\.\-]+)/
            hash = {
              rank: $1.to_i, skater_name: $2, nation: $3, starting_number: $4.to_i,
              tss: $5.to_f, tes: $6.to_f, pcs: $7.to_f, deductions: $8.to_f,
            }
            score.merge!(hash)
            mode = :tes
          end
        when :tes
          element_re = '[\w\+\!<\*]+'
          #binding.pry if additional_entries[:category] == "MEN"
          if line =~ /^(\d+) (#{element_re}) ([<>\!\*e]*) *([\d\.]+) ([Xx]?) *([\d\.\-]+) ([\d\- ]+) ([\d\.\-]+)$/
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
      score
    end
    
    def parse(score_url)
      text = convert_pdf(score_url, dir: "pdf")
      text = text.force_encoding('UTF-8').gsub(/  +/, ' ').gsub(/^ */, '').gsub(/\n\n+/, "\n").chomp
      
      text =~ /^(.*)\n(.*) ((SHORT|FREE) (.*)) JUDGES DETAILS PER SKATER$/

      additional_entries = {
        competition_name: $1,
        category: $2,
        segment: $3,
      }
      scores = []
      page_number = 1
      text.split(/\f/).map do |page_text|
        page_text.split(/^Rank/)[1..-1].each_with_index do |t, i|
          result_pdf =  "#{score_url}\#page=#{i+1}"
          score = parse_score(t, additional_entries: additional_entries)
          scores << score.merge(result_pdf: result_pdf)
        end
      end
      return scores
    end  # def parser
  end
end

################################################################
if $0 == __FILE__
  txt = "data0205.txt"
  parser = Fisk8Viewer::ScoreParser.new
  parser.parse_score(File.read(txt))
end

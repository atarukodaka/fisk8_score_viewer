require 'fisk8viewer/parser/competition_summary_parser'
require 'fisk8viewer/parser/category_result_parser'
require 'fisk8viewer/parser/score_parser'

module Fisk8Viewer
  class Parser
    def parse_competition_summary(url)
      self.class.const_get(:CompetitionSummaryParser).new.parse(url)
    end
    def parse_category_result(url)
      self.class.const_get(:CategoryResultParser).new.parse(url)
    end
    def parse_score(url)
      self.class.const_get(:ScoreParser).new.parse(url)
    end
  end ## Parser module
end



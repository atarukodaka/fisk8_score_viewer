require 'fisk8viewer/parsers/isu_generic'

module Fisk8Viewer
  module Parsers
    class ISU_Generic_Mdy < ISU_Generic
      class CompetitionSummaryParser < ISU_Generic::CompetitionSummaryParser
        def parse_datetime(str)
          dt_str, tm_str = str.split(/ /)
          m, d, y = dt_str.split(/[,\/]/)
          dt_str = "%s/%s/%s" % [d, m, y]
          Time.zone.parse("#{dt_str} #{tm_str}")
        end
      end
      Fisk8Viewer::Parsers.register(:isu_generic_mdy, self)
    end ## Mdy
  end
end



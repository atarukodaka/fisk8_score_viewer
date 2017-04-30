module Fisk8Viewer
  module Parsers
    class ISU_Generic < Parser
      Fisk8Viewer::Parsers.register(:isu_generic, self)
    end
  end
  
end

module Fisk8Viewer
  module Parsers
    class ISU_Generic_mdy < ISU_Generic
      def parse_datetime(str)
        dt_str, tm_str = str.split(/ /)
        m, d, y = dt_str.split(/[,\/]/)
        dt_str = "%s/%s/%s" % [d, m, y]
        Time.zone.parse("#{dt_str} #{tm_str}")
      end
      Fisk8Viewer::Parsers.register(:isu_generic_mdy, self)
    end
  end
end

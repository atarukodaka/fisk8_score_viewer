require 'fisk8viewer/parser'

module Fisk8Viewer
  module Parsers
    class ISU_Generic < Fisk8Viewer::Parser
      Fisk8Viewer::Parsers.register(:isu_generic, self)
    end
  end
end

module Muskox
  module Extensions
    def add_parser name, schema
      parsers[name] = Muskox.generate schema
    end

    def parsers
      @_parsers||={}
    end
  end
end
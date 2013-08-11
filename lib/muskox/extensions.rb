module Muskox
  module Extensions
    def add_parser name, schema
      schema = deep_stringify schema
      parsers[name] = Parser.new schema
    end

    def parsers
      @_parsers||={}
    end

    private

    def deep_stringify hash
      hash.inject({}) do |new_hash, tuple|
        key = tuple[0].to_s
        value = case tuple[1]
                when Hash
                 deep_stringify tuple[1]
                when Array
                 tuple[1].map{|v| v.kind_of?(Hash) ? deep_stringify(v) : v }
                when Symbol
                 tuple[1].to_s 
                else
                 tuple[1]
                end
        new_hash[key]= value
        new_hash  
      end

    end
  end
end
module Muskox
  module DSL

    def self.schemafy schema
      s = deep_stringify schema
      deep_additional_propertyify! s
      s
    end

    private

    def self.deep_stringify hash
      hash.inject({}) do |new_hash, tuple|
        key = tuple[0].to_s
        value = case tuple[1]
                when Hash
                 deep_stringify tuple[1]
                when Array
                 tuple[1].map do |v|
                   case v
                   when Hash
                     deep_stringify v
                   when Symbol
                     v.to_s
                   else
                     v
                   end
                 end
                when Symbol
                 tuple[1].to_s 
                else
                 tuple[1]
                end
        new_hash[key]= value
        new_hash  
      end
    end

    def self.deep_additional_propertyify! schema
      case schema["type"]
      when "object"
        return unless schema["properties"]
        schema["additionalProperties"] = false unless schema.key? "additionalProperties"

        schema["properties"].each do |k, subschema|
          deep_additional_propertyify! subschema
        end
      when "array"
        case schema["items"]
        when Hash
          deep_additional_propertyify! schema["items"]
        when Array
          schema["items"].each {|i| deep_additional_propertyify! i}
        end
      end
    end
  end
end
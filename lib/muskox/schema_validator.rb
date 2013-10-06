module Muskox

  class InvalidSchemaError < StandardError
    
  end

  module SchemaValidator
    def self.validate schema
      if schema.empty?
        raise InvalidSchemaError, "Muskox doesn't accept empty schema"
      end
      raise InvalidSchemaError, "Unknown type: #{schema["type"]}" unless Types::ALL.include?(schema["type"])
      case schema["type"]
      when "object"
        additional_properties = schema["additionalProperties"]
        if additional_properties != false
          raise InvalidSchemaError, "Muskox requires additionalProperties to be false on object schemas"
        end
        if schema["properties"].nil?
          raise InvalidSchemaError, "Muskox requires properties to be defined in object schemas"
        end
        if schema["required"]
          missing_required_defs = schema["required"].select { |r| !schema["properties"].keys.include? r }
          unless missing_required_defs.empty?
            raise InvalidSchemaError, "Missing definition for required properties: [#{missing_required_defs.join ", "}]"
          end
        end
        schema["properties"].each do |key, sub_schema|
          validate sub_schema
        end
      when "array"
        if schema["items"].nil?
          raise InvalidSchemaError, "Muskox requires items to be defined in array schemas"
        end
        case schema["items"]
        when Hash
          validate schema["items"]
        when Array
          schema["items"].each do |sub_schema|
            validate sub_schema
          end
        end
      end
          
    end
  end

end
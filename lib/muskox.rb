require "muskox/version"
require "muskox/dsl"
require "muskox/schema_validator"
require "muskox/json_lexer"
require "muskox/parser"
require "muskox/extensions"


module Muskox
  def self.generate schema
    generate_raw DSL.schemafy(schema)
  end

  def self.generate_raw schema
    SchemaValidator.validate schema
    Parser.new schema
  end
end

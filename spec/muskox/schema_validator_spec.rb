# - require additionalProperties: false
# - require type specified on all schemas
require "spec_helper"

describe Muskox::SchemaValidator do
  def self.it_accepts name, schema
    it "accepts #{name}" do
      Muskox::SchemaValidator.validate schema
    end
  end
  def self.it_blows_up_on name, message, schema
    it "blows up on #{name}" do
      e = assert_raises Muskox::InvalidSchemaError do
        Muskox::SchemaValidator.validate(schema)
      end
      e.message.must_equal message
    end
  end

  describe ".validate" do
    describe "type" do
      it_blows_up_on "unknown types", "Unknown type: foo", {"type" => "foo"}
    end
    describe "objects" do
      it_accepts "schema with well formed property schemas",
                  "type" => "object",
                  "properties" => {
                    "number" => {
                      "type" => "integer"
                    }
                  },
                  "additionalProperties" => false
      it_accepts "schema with no required properties",
                  "type" => "object",
                  "properties" => { },
                  "additionalProperties" => false
      it_accepts "schema with no defined properties",
                  "type" => "object",
                  "properties" => { },
                  "additionalProperties" => false
      it_blows_up_on "schema with missing properties",
                  "Muskox requires properties to be defined in object schemas",
                  "type" => "object",
                  "additionalProperties" => false

      it_blows_up_on "missing additionalProperties",
                  "Muskox requires additionalProperties to be false on object schemas",
                  "type" => "object",
                  "properties" => { }
      it_blows_up_on "true additionalProperties",
                  "Muskox requires additionalProperties to be false on object schemas",
                  "type" => "object",
                  "properties" => { },
                  "additionalProperties" => true

      it_blows_up_on "missing required property definition",
                  "Missing definition for required properties: [number]",
                  "type" => "object",
                  "properties" => { },
                  "required" => ["number"],
                  "additionalProperties" => false
      it_blows_up_on "schema with empty property schemas",
                  "Muskox doesn't accept empty schema",
                  "type" => "object",
                  "properties" => {
                    "number" => { }
                  },
                  "additionalProperties" => false

    end
    describe "array" do
      it_accepts "schema with items as hash",
                     "type" => "array",
                     "items" => {"type" => "string"}
      it_accepts "schema with items as array",
                     "type" => "array",
                     "items" => [{"type" => "string"}]
      it_accepts "schema with items as empty array",
                    "type" => "array",
                    "items" => []
      it_blows_up_on "schema with empty items as hash",
                     "Muskox doesn't accept empty schema",
                     "type" => "array",
                     "items" => { }
      it_blows_up_on "schema with missing items",
                     "Muskox requires items to be defined in array schemas",
                     "type" => "array"
      it_blows_up_on "schema with items as array containing invalid schema",
                     "Muskox doesn't accept empty schema",
                    "type" => "array",
                    "items" => [{}]

    end

    it_blows_up_on("an empty schema", "Muskox doesn't accept empty schema", {})
  end  
end
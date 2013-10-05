require 'spec_helper'

describe Muskox::ParserError do
  describe "simple object[number]=integer schema, error on extra property" do
    let(:parser) do
      Muskox.generate "type" => "object",
        "properties" => {
          "number" => {
            "type" => "integer"
          }
        },
        "required" => ["number"]
    end
    it "error for an extra property has a good message" do
      error = assert_raises Muskox::ParserError do
        result = parser.parse %!{"number": 2, "grug":[]}!
      end
      assert_equal "Unexpected property: [grug] at root. Allowed properties: [number]", error.message
    end
  end
end
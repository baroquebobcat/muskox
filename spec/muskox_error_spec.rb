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

    let(:error) do
      assert_raises Muskox::UnexpectedProperty do
        parser.parse %!{"number": 2, "grug":[]}!
      end
    end

    it "has a good message" do
      assert_equal "Unexpected property: [grug] at root. Allowed properties: [number]", error.message
    end

    it "exposes the unexpected property" do
      assert_equal "grug", error.unexpected_property
    end

    it "exposes the permitted properties" do
      assert_equal ["number"], error.permitted_properties
    end
  end
end
require 'minitest/autorun'
require 'muskox'

describe Muskox do  
  describe "simple object[number]=integer schema, error on extra property" do
    before do
      schema = {
        "title" => "Schema",
        "type" => "object",
        "properties" => {
          "number" => {
            "type" => "integer"
          }
        },
        "required" => ["number"]
      }
      
      @parser = Muskox.generate schema
    end
    it "parses successfully when passed a valid string" do
      result = @parser.parse %!{"number": 1}!
      assert_equal({"number" => 1 }, result)
    end

    it "parses successfully when passed a different valid string" do
      result = @parser.parse %!{"number": 2}!
      assert_equal({"number" => 2 }, result)
    end

    it "raises an error when there is an extra property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"number": 2, "grug":[]}!
      end
    end
    it "raises an error when there is an invalid type of property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"number": "string-not-number"}!
      end
    end
  end
end


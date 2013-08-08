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
    it "raises an error when there is a missing property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{}!
      end
    end

  end


  describe "simple object[string]=string schema, error on extra property" do
    before do
      schema = {
        "title" => "Schema",
        "type" => "object",
        "properties" => {
          "string" => {
            "type" => "string"
          }
        },
        "required" => ["string"]
      }
      
      @parser = Muskox.generate schema
    end
    it "parses successfully when passed a valid string" do
      result = @parser.parse %!{"string": "one"}!
      assert_equal({"string" => "one" }, result)
    end

    it "parses successfully when passed a different valid string" do
      result = @parser.parse %!{"string": "two"}!
      assert_equal({"string" => "two" }, result)
    end

    it "raises an error when there is an extra property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"string": "two", "grug":[]}!
      end
    end
    it "raises an error when there is an invalid type of property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"string": 1701}!
      end
    end
  end

  describe " object[array]=array[string] schema, error on extra property" do
    before do
      schema = {
        "title" => "Schema",
        "type" => "object",
        "properties" => {
          "array" => {
            "type" => "array",
            "items" => {"type" => "string"}
          }
        },
        "required" => ["array"]
      }
      
      @parser = Muskox.generate schema
    end
    it "parses successfully when passed a valid string" do
      result = @parser.parse %!{"array": ["one"]}!
      assert_equal({"array" => ["one"] }, result)
    end

    it "parses successfully when passed a different valid array" do
      result = @parser.parse %!{"array": ["two"]}!
      assert_equal({"array" => ["two"] }, result)
    end

    it "parses successfully when passed a valid array of size 2" do
      result = @parser.parse %!{"array": ["two", "one"]}!
      assert_equal({"array" => ["two", "one"] }, result)
    end

    it "raises an error when there is an extra property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"array": ["two"], "grug":[]}!
      end
    end

    it "raises an error when there is an invalid component type of property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"array": [1701]}!
        p result
      end
    end
  end


  describe "object[object]=object schema, error on extra property" do
    before do
      schema = {
        "title" => "Schema",
        "type" => "object",
        "properties" => {
          "object" => {
            "type" => "object"
          }
        },
        "required" => ["object"]
      }
      
      @parser = Muskox.generate schema
    end
    it "parses successfully when passed a valid string" do
      result = @parser.parse %!{"object": {}}!
      assert_equal({"object" => {} }, result)
    end

    it "parses successfully when passed a different valid string" do
      result = @parser.parse %!{"object": {}}!
      assert_equal({"object" => {} }, result)
    end

    it "raises an error when there is an extra property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"object": {}, "grug":[]}!
      end
    end
    it "raises an error when there is an invalid type of property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"object": "string"}!
      end
    end
  end

  describe "object[object]=object[string]=string schema, error on extra property" do
    before do
      schema = {
        "title" => "Schema",
        "type" => "object",
        "properties" => {
          "object" => {
            "type" => "object",
            "properties" => {"string" => {"type" => "string"}},
            "required" => ["string"]
          }
        },
        "required" => ["object"]
      }
      
      @parser = Muskox.generate schema
    end
    it "parses successfully when passed a valid string" do
      result = @parser.parse %!{"object": {"string":"a"}}!
      assert_equal({"object" => {"string" => "a"} }, result)
    end

    it "parses successfully when passed a different valid string" do
      result = @parser.parse %!{"object": {"string":"b"}}!
      assert_equal({"object" => {"string" => "b"} }, result)
    end

    it "raises an error when there is an extra nested property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"object": {"string":"a","grug":[]}, }!
      end
    end

    it "raises an error when there is an invalid type of nested property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"object": {"string":1}}!
      end
    end
  end

  describe "simple object[number]=float happy path" do
    before do
      schema = {
        "title" => "Schema",
        "type" => "object",
        "properties" => {
          "number" => {
            "type" => "float"
          }
        },
        "required" => ["number"]
      }
      
      @parser = Muskox.generate schema
    end
    it "parses successfully when passed a valid string" do
      result = @parser.parse %!{"number": 1.0}!
      assert_equal({"number" => 1.0 }, result)
    end
  end


  describe "simple object[number]=boolean happy path" do
    before do
      schema = {
        "title" => "Schema",
        "type" => "object",
        "properties" => {
          "number" => {
            "type" => "boolean"
          }
        },
        "required" => ["number"]
      }
      
      @parser = Muskox.generate schema
    end
    it "parses successfully when passed a valid string" do
      result = @parser.parse %!{"number": true}!
      assert_equal({"number" => true }, result)
    end
  end

  describe "malformed json handling" do
    before do
      schema = {
        "type" => "object",
        "properties" => {
          "number" => {
            "type" => "boolean"
          }
        },
        "required" => ["number"]
      }
      
      @parser = Muskox.generate schema
    end
    it "raises an error when object unended" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"number": true!
      end
    end
  end

  describe "object[array]=array[object] schema, error on extra property" do
    before do
      schema = {
        "title" => "Schema",
        "type" => "object",
        "properties" => {
          "array" => {
            "type" => "array",
            "items" => {"type" => "object"}
          }
        },
        "required" => ["array"]
      }
      
      @parser = Muskox.generate schema
    end
    it "parses successfully when passed a valid string" do
      result = @parser.parse %!{"array": [{}]}!
      assert_equal({"array" => [{}] }, result)
    end

    it "parses successfully when passed a different valid string" do
      result = @parser.parse %!{"array": [{},{}]}!
      assert_equal({"array" => [{},{}] }, result)
    end

    it "raises an error when there is an extra nested property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"array": [{"grug":[]}]}!
      end
    end

    it "raises an error when there is an invalid type of nested property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"array": [1]}!
      end
    end
  end

  describe "object[array]=array[]=array[strings] schema, error on extra property" do
    before do
      schema = {
        "title" => "Schema",
        "type" => "object",
        "properties" => {
          "array" => {
            "type" => "array",
            "items" => {"type" => "array", "items"=>{"type" => "string"}}
          }
        },
        "required" => ["array"]
      }
      
      @parser = Muskox.generate schema
    end
    it "parses successfully when passed a valid string" do
      result = @parser.parse %!{"array": [[]]}!
      assert_equal({"array" => [[]] }, result)
    end

    it "parses successfully when passed a different valid string" do
      result = @parser.parse %!{"array": [[],[]]}!
      assert_equal({"array" => [[],[]] }, result)
    end

    it "raises an error when there is an extra nested property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"array": [[{"grug":[]}]]}!
      end
    end

    it "raises an error when there is an invalid type of nested property" do
      assert_raises Muskox::ParserError do
        result = @parser.parse %!{"array": [[],1]}!
      end
    end
  end


#null
  #array size limits
# bad JSON strings

end


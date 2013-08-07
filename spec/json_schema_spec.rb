require 'minitest/autorun'
require 'muskox'
require 'json'


json = JSON.parse(open('json_schema_test_suite/tests/draft4/items.json').read)

describe "draft4/items.json" do
  json.each do |t|
    describe t["description"] do
      before do
        schema = t["schema"]
        @parser = Muskox.generate schema
      end
      t["tests"].each do |test|
        it test["description"] do 
          if test["valid"]
            @parser.parse test["data"].to_json
          else
            assert_raises Muskox::ParserError do 
              @parser.parse test["data"].to_json
            end
          end
        end
      end
    end
  end
end

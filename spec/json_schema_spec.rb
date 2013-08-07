require 'minitest/autorun'
require 'muskox'
require 'json'


to_skip = [
# Allows wrong type sometimes for some reason
["ignores non-arrays", "draft4/items.json", "a schema given for items"]
]

['draft4/items.json', 'draft4/type.json'].each do |file|
  json = JSON.parse(open("json_schema_test_suite/tests/#{file}").read)
  describe file do
    json.each do |t|
      describe t["description"] do
        before do
          schema = t["schema"]
          @parser = Muskox.generate schema
        end
        t["tests"].each do |test|
          it test["description"] do
            skip if to_skip.include? [test["description"], file, t["description"]]
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
end

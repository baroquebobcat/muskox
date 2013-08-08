require 'minitest/autorun'
require 'muskox'
require 'json'


to_skip = [
           # Allows wrong type sometimes for some reason
           ["ignores non-arrays", "draft4/items.json", "a schema given for items"],
           
           ["doesn't invalidate other properties","draft4/properties.json","object properties validation"],
           
           # patternProperties kind of defeat the purpose, so I'm ignoring them
           # they introduce regexes and fuzziness back into the spec :-/
           ["property invalidates property", "draft4/properties.json", "properties, patternProperties, additionalProperties interaction"],
           ["property validates property", "draft4/properties.json", "properties, patternProperties, additionalProperties interaction"],
           ["patternProperty validates nonproperty","draft4/properties.json","properties, patternProperties, additionalProperties interaction"],
           ["additionalProperty validates others","draft4/properties.json","properties, patternProperties, additionalProperties interaction"],
           ["patternProperty invalidates property","draft4/properties.json","properties, patternProperties, additionalProperties interaction"]
]

['draft4/items.json', 'draft4/type.json', 'draft4/properties.json', 'draft4/required.json'].each do |file|
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

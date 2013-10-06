require 'spec_helper'

describe Muskox::Extensions do
  describe '#add_parser' do
    before do
      @klass = Class.new do
        extend Muskox::Extensions
        add_parser    :user,
          type:       :object,
          properties: {
            name:  { type: :string },
            email: { type: :string }
          }
      end
    end

    it 'adds a parsers method with a hash of named parsers' do
      assert @klass.parsers[:user], "expected there to be a :user parser"
      assert @klass.parsers[:user].respond_to?(:parse), "expected :user to know how to parse"
    end

    it 'creates a working parser' do
      result = @klass.parsers[:user].parse %q[{"name": "bobby drop tables", "email":"b@example.com"}]
      assert_equal({"name" => "bobby drop tables",
                    "email" => "b@example.com"},
                   result)
    end
    # TODOs
    # - validate schema
    # - ensure no overwrite
  end
end
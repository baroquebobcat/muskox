module Muskox
  module Types
    SCALAR = [:integer, :string, :float, :boolean, :null]

    TYPE_WIDENINGS = {
      'integer' => 'number',
      'float' => 'number'
    }
    
    def self.is_type expected, actual
      case expected
      when String
        expected == actual || expected == TYPE_WIDENINGS[actual]
      when Array
        expected.any? {|e| is_type e, actual }
      when nil
        true # is this really what the spec wants? really?
      else
        raise "unexpected type comparison #{expected}, #{actual}"
      end
    end
  end
end
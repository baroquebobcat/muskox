require "muskox/version"
require "muskox/json_lexer"

module Muskox
  def self.generate schema
    Parser.new schema
  end

  class Parser
    ROOT = nil
    attr_reader :schema
    def initialize schema
      @schema = schema
    end

    def parse input
      r = nil
      schema_stack = [schema]
      stack = [[ROOT, ROOT]]
      lexer = Pure::Lexer.new input, :quirks_mode => true
      lexer.lex do |type, value|
#        puts "token #{type}: #{value}"
#        puts "stack #{stack.inspect}"
#        puts "schema stack #{schema_stack.last["type"]}"
        case type
        when :property
          if schema_stack.last["properties"] && schema_stack.last["properties"].keys.include?(value)
            stack.push [type, value]
          else
            raise ParserError, "Unexpected property: #{value}"
          end
        when :array_begin
          case stack.last.first
          when :property
            last = stack.last
            matching_type expected_type(schema_stack.last, last), "array" do
              stack.push [:array, []]
              schema_stack.push(schema["properties"][last.last])
            end
          when ROOT
            stack.push [:array, []]
          else
            raise "unknown stack type #{stack.last}"
          end
        when :array_end
          array_top = stack.pop

          case stack.last.first
          when :property
            schema_stack.pop
            handle_property stack, schema_stack, "array", array_top.last
          when :array
            matching_type expected_type(schema_stack.last, last), "array" do
              stack.last.last << array_top.last
            end
          when ROOT
            matching_type schema_stack.last["type"], "array" do
              r = stack.last.last
            end
          else
            raise "unknown stack type #{stack.last}"
          end
        when :object_begin
          case stack.last.first
          when :property
            last = stack.last
            matching_type expected_type(schema_stack.last, last), "object" do
              stack.push [:object, {}]
              schema_stack.push(schema_stack.last["properties"][last.last])
            end
          when :array
            last = stack.last
            for_array stack, schema_stack, "object" do |scope|
              stack.push [:object, {}]
              schema_stack.push scope
            end
          when ROOT
            stack.push [:object, {}]
          else
            raise "unknown stack type #{stack.last}"
          end
        when :object_end
          object_top = stack.pop

          if schema_stack.last["required"] && !(schema_stack.last["required"] - object_top.last.keys).empty?
            raise ParserError, "missing required keys #{schema_stack.last["required"] - object_top.last.keys}"
          end

          case stack.last.first
          when :property
            schema_stack.pop
            handle_property stack, schema_stack, "object", object_top.last
          when :array
            schema_stack.pop
            # we've already validated the type on object_begin, so...
            stack.last.last << object_top.last
          when ROOT
            matching_type schema_stack.last["type"], "object" do
              r = object_top.last
            end
          else
            raise "unknown stack type #{stack.last.first}"
          end
        when :integer, :string, :float, :boolean, :null
          case stack.last.first
          when :property
            handle_property stack, schema_stack, type, value
          when :array
            for_array stack, schema_stack, type do |scope|
              stack.last.last << value
            end
          when ROOT
            matching_type schema_stack.last["type"], type do
              r = stack.last.last
            end
          else
            raise "unknown stack type #{stack.last.inspect}"
          end
        else
          raise "unhandled token type: #{type}: #{value}"
        end
      end
      r
    end

    def handle_property stack, schema_stack, type, value
      last = stack.pop
      matching_type expected_type(schema_stack.last, last), type, stack.last.first == :object do
        stack.last.last[last.last] = value
      end
    end

    def for_array stack, schema_stack, type
      case schema_stack.last["items"]
      when Hash
        matching_type schema_stack.last["items"]["type"], type do
          yield schema_stack.last["items"]
        end
      when Array
        matching_type schema_stack.last["items"][stack.last.last.size]["type"], type do
          yield schema_stack.last["items"][stack.last.last.size]
        end
      when nil
        raise '"items" schema definition for array is missing'
      else
        raise "Unexpected items type #{schema_stack.last["items"]}"
      end
    end

    def expected_type schema, last
      schema["properties"][last.last] && schema["properties"][last.last]["type"]
    end

    def matching_type expected, actual, opt=true
      if is_type(expected, actual.to_s) && opt
        yield
      else
        raise ParserError, "expected node of type #{expected} but was #{actual}"
      end
    end

    TYPE_WIDENINGS = {
      'integer' => 'number',
      'float' => 'number'
    }
    def is_type expected, actual
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

  class ParserError < StandardError
  end

end

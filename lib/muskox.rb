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
      lexer = Pure::Lexer.new input
      lexer.lex do |type, value|
#        puts "token #{type}: #{value}"
#        puts "stack #{stack.inspect}"
#        puts "schema stack #{schema_stack.last["type"]}"
        case type
        when :property
          stack.push [type, value]
        when :array_begin
          case stack.last.first
          when :property
            last = stack.last
            matching_type expected_type(schema_stack.last, last), "array" do
              stack.push [:array, []]
              schema_stack.push(schema["properties"][last.last])
            end
          end
        when :array_end
          array_top = stack.pop
          schema_stack.pop
          case stack.last.first
          when :property
            last = stack.pop
            matching_type expected_type(schema_stack.last, last), "array" do
              stack.last.last[last.last] = array_top.last
            end
          else
            raise "unknown stack type #{stack.last.first}"
          end
        when :object_begin
          case stack.last.first
          when :property
            last = stack.last
            matching_type expected_type(schema_stack.last, last), "object" do
              stack.push [:object, {}]
              schema_stack.push(schema["properties"][last.last])
            end
          when ROOT
            stack.push [:object, {}]
          end
        when :object_end
          object_top = stack.pop

          if schema_stack.last["required"] && !(schema_stack.last["required"] - object_top.last.keys).empty?
            raise ParserError
          end

          case stack.last.first
          when :property
            schema_stack.pop
            last = stack.pop
            matching_type expected_type(schema_stack.last, last), "object", stack.last.first == :object do
              stack.last.last[last.last] = object_top.last
            end
          when ROOT
            r = object_top.last
          else
            raise "unknown stack type #{stack.last.first}"
          end
        when :integer, :string, :float, :boolean
          case stack.last.first
          when :property
            last = stack.pop
            matching_type expected_type(schema_stack.last, last), type, stack.last.first == :object do
              stack.last.last[last.last] = value
            end
          when :array
            matching_type schema_stack.last["items"]["type"], type do
              stack.last.last << value
            end
          else
            raise "unknown stack type #{stack.last.first}"
          end
        else
          raise "unhandled token type: #{type}: #{value}"
        end
      end
      r
    end

    def expected_type schema, last
      schema["properties"][last.last] && schema["properties"][last.last]["type"]
    end

    def matching_type expected, actual, opt=true
      if expected == actual.to_s && opt
        yield
      else
        raise ParserError
      end
    end
  end

  class ParserError < StandardError
  end

end

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
            if expected_type(schema_stack.last, last) == "array"
              stack.push [:array, []]
              schema_stack.push(schema["properties"][last.last])
            else
              raise ParserError
            end
          end
        when :array_end
          array_top = stack.pop
          schema_stack.pop
          case stack.last.first
          when :property
            last = stack.pop
            if expected_type(schema_stack.last, last) == "array"
              stack.last.last[last.last] = array_top.last
            else
              raise ParserError
            end
          else
            raise "unknown stack type #{stack.last.first}"
          end
        when :object_begin
          case stack.last.first
          when :property
            last = stack.last
            if expected_type(schema_stack.last, last) == "object"
              stack.push [:object, {}]
              schema_stack.push(schema["properties"][last.last])
            else
              raise ParserError
            end
          when ROOT
            stack.push [:object, {}]
          end
        when :object_end
          object_top = stack.pop
          
          case stack.last.first
          when :property
            schema_stack.pop
            last = stack.pop
            if expected_type(schema_stack.last, last) == "object" && stack.last.first == :object
              stack.last.last[last.last] = object_top.last
            else
              raise ParserError
            end
          when ROOT
            r = object_top.last
          else
            raise "unknown stack type #{stack.last && stack.last.first}"
          end

        when :integer, :string
          case stack.last.first
          when :property
            last = stack.pop
            if expected_type(schema_stack.last, last) == type.to_s && stack.last.first == :object
              stack.last.last[last.last] = value
            else
              raise ParserError
            end
          when :array
            if schema_stack.last["items"]["type"] == type.to_s
              stack.last.last << value
            else
              raise ParserError
            end
          else
            raise "unknown stack type #{stack.last.first}"
          end
        end
      end
      r
    end

    def expected_type schema, last
      schema["properties"][last.last] && schema["properties"][last.last]["type"]
    end
  end

  class ParserError < StandardError
  end

end

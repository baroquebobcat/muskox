require 'muskox/types'

module Muskox

  class ParserError < StandardError
  end

  class UnexpectedProperty < ParserError
    attr_reader :unexpected_property, :permitted_properties

    def initialize unexpected_property, permitted_properties
      super "Unexpected property: [#{unexpected_property}] at root. Allowed properties: [#{permitted_properties.join(", ")}]"
      @unexpected_property = unexpected_property
      @permitted_properties = permitted_properties
    end
  end

  class Parser
    attr_reader :schema

    def initialize schema
      @schema = schema
    end

    def parse input
      schema_stack = [schema]
      stack = [[:root, nil]]
      lexer = Pure::Lexer.new input, :quirks_mode => true
      lexer.lex do |type, value|
#        puts "token #{type}: #{value}"
#        puts "stack #{stack.inspect}"
#        puts "schema stack #{schema_stack.last["type"]}"
        case type
        when :property
          unless expected_property? schema_stack, value
            raise UnexpectedProperty.new value,
                                         schema_stack.last.fetch("properties", {}).keys
          end
          stack.push [type, value]
        when :array_begin
          x_begin stack, schema_stack, [:array, []]
        when :object_begin
          x_begin stack, schema_stack, [:object, {}]
        when :array_end
          x_end stack, schema_stack
        when :object_end
          unless includes_required_properties? stack, schema_stack
            raise ParserError, "missing required keys #{schema_stack.last["required"] - stack.last.last.keys}"
          end
          x_end stack, schema_stack
        when *Types::SCALAR
          handle_scalar stack, schema_stack, type, value
        else
          raise "unhandled token type: #{type}: #{value}"
        end
      end
      _, result = stack.pop
      result
    end

    private

    def handle_scalar stack, schema_stack, type, value
      case stack.last.first
      when :property
        handle_property stack, schema_stack, type, value
      when :array
        handle_array stack, schema_stack, type do |scope|
          stack.last.last << value
        end
      when :root
        matching_type schema_stack.last["type"], type do
          stack.last[-1] = value
        end
      else
        raise "unknown stack type #{stack.last.inspect}"
      end
    end

    def expected_property? schema_stack, value
      schema_stack.last["properties"] && schema_stack.last["properties"].keys.include?(value)
    end

    def includes_required_properties? stack, schema_stack
      ((schema_stack.last["required"]||[]) - stack.last.last.keys).empty?
    end

    def x_begin stack, schema_stack, stack_value
      case stack.last.first
      when :property
        last = stack.last
        matching_type expected_type(schema_stack.last, last), stack_value.first.to_s do
          stack.push stack_value
          schema_stack.push(schema["properties"][last.last])
        end
      when :array
        last = stack.last
        handle_array stack, schema_stack, stack_value.first.to_s do |scope|
          stack.push stack_value
          schema_stack.push scope
        end
      when :root
        stack.push stack_value
      else
        raise "unknown stack type #{stack.last}"
      end
    end

    def x_end stack, schema_stack
      type, value = stack.pop
      case stack.last.first
      when :property
        schema_stack.pop
        handle_property stack, schema_stack, type.to_s, value
      when :array
        schema_stack.pop
        # we've already validated the type on object_begin, so...
        stack.last.last << value
      when :root
        matching_type schema_stack.last["type"], type.to_s do
          stack.last[-1] = value
        end
      else
        raise "unknown stack type #{stack.last.first}"
      end
    end

    def handle_property stack, schema_stack, type, value
      last = stack.pop
      matching_type expected_type(schema_stack.last, last), type, stack.last.first == :object do
        stack.last.last[last.last] = value
      end
    end

    def handle_array stack, schema_stack, type
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
      if Types.is_type(expected, actual.to_s) && opt
        yield
      else
        raise ParserError, "expected node of type #{expected} but was #{actual}"
      end
    end
  end
end
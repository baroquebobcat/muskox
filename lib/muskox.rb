require "muskox/version"
require "muskox/json_lexer"

module Muskox
  def self.generate schema
    Parser.new schema
  end

  class Parser
    attr_reader :schema
    def initialize schema
      @schema = schema
    end
    def parse input
      stack = []
      r = {}
      lexer = Pure::Lexer.new input
      lexer.lex do |type, value|
        case type
        when :property
          stack.push [type, value]
        when :integer, :string
          if stack.last.first == :property
            last = stack.pop
            expected_type = schema["properties"][last.last] && schema["properties"][last.last]["type"]
            if expected_type == type.to_s
              r[last.last] = value
            else
              raise ParserError
            end
          end
        end
      end
      r
    end
  end

  class ParserError < StandardError
  end

end

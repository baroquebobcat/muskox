require "muskox/version"
require "muskox/json_lexer"
require "muskox/parser"

module Muskox
  def self.generate schema
    Parser.new schema
  end
end

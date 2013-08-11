require "muskox/version"
require "muskox/json_lexer"
require "muskox/parser"
require "muskox/extensions"


module Muskox
  def self.generate schema
    Parser.new schema
  end
end

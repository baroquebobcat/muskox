require "muskox/version"

require 'json'

module Muskox
  def self.generate schema
    Parser.new
  end

  class Parser
    def parse input
      r = JSON.parse input
      if r.keys.size > 1 || r.first.last.kind_of?(String)
        raise ParserError
      end
      r
    end
  end

  class ParserError < StandardError
  end
end

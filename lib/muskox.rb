require "muskox/version"

require 'json'

module Muskox
  def self.generate schema
    Parser.new
  end

  class Parser
    def parse input
      r = JSON.parse input
      if r.keys.size > 1
        raise ParserError
      end
      r
    end
  end

  class ParserError < StandardError
  end
end

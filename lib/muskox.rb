require "muskox/version"

require 'json'

module Muskox
  def self.generate schema
    Parser.new
  end

  class Parser
    def parse input
      JSON.parse input
    end
  end
end

require "muskox/version"

module Muskox
  def self.generate schema
    Parser.new
  end

  class Parser
    def parse input
      {"number" => 1}
    end
  end
end

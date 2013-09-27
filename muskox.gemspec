# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'muskox/version'

Gem::Specification.new do |spec|
  spec.name          = "muskox"
  spec.version       = Muskox::VERSION
  spec.authors       = ["Nick Howard"]
  spec.email         = ["ndh@baroquebobcat.com"]
  spec.description   = %q{A JSON-Schema based Parser-Generator}
  spec.summary       = %q{A JSON-Schema based Parser-Generator}
  spec.homepage      = "https://github.com/baroquebobcat/muskox"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'simple_pin/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_pin"
  spec.version       = "0.1.0"
  spec.authors       = ["StevenIseki"]
  spec.email         = ["stevenisekimartin@gmail.com"]
  spec.summary       = "simple_pin gem for pin-payments"
  spec.description   = "A simple gem for creating customers and charges using pin-payments (pin.net.au) API"
  spec.homepage      = "https://github.com/StevenIseki/simple_pin"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end

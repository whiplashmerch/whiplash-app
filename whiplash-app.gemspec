# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'whiplash/app/version'

Gem::Specification.new do |spec|
  spec.name          = "whiplash-app"
  spec.version       = Whiplash::App::VERSION
  spec.authors       = ["Don Sullivan, Mark Dickson"]
  spec.email         = ["developers@getwhiplash.com"]

  spec.summary       = "this gem provides connectivity to the Whiplash API for authentication and REST requests."
  spec.description   = "this gem provides connectivity to the Whiplash API for authentication and REST requests."
  spec.homepage      = "https://github.com/whiplashmerch/whiplash-app"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "oauth2", "~> 2.0.4"
  spec.add_dependency "faraday", "~> 2.7"
  spec.add_dependency 'faraday-net_http_persistent'

  spec.add_development_dependency "bundler", ">= 2.2"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.14"
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid/publishing_logic/version'

Gem::Specification.new do |spec|
  spec.name          = "mongoid-publishing_logic"
  spec.version       = Mongoid::PublishingLogic::VERSION
  spec.authors       = ["Joakim Reinert"]
  spec.email         = ["mail@jreinert.com"]
  spec.summary       = %q{A set of methods and scopes for publishing logic in mongoid models}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "https://github.com/jreinert/mongoid-publishing_logic"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mongoid", "~> 4.0.0"
  spec.add_dependency "activesupport", "~> 4.1.5"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-doc"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "simplecov"
end

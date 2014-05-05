# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'build_box/version'

Gem::Specification.new do |spec|
  spec.name          = "build_box"
  spec.version       = BuildBox::VERSION
  spec.authors       = ["Rafael Vettori"]
  spec.email         = ["rafael.vettori@gmail.com"]
  spec.summary       = %q{BuidBolx try apply security in execution your ruby code when unknown source.}
  spec.description   = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end

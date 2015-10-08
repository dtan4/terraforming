# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'terraforming/version'

Gem::Specification.new do |spec|
  spec.name          = "terraforming"
  spec.version       = Terraforming::VERSION
  spec.authors       = ["Daisuke Fujita"]
  spec.email         = ["dtanshi45@gmail.com"]

  spec.summary       = %q{Export existing AWS resources to Terraform style (tf, tfstate)}
  spec.description   = %q{Export existing AWS resources to Terraform style (tf, tfstate)}
  spec.homepage      = "https://github.com/dtan4/terraforming"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "~> 2.1.15"
  spec.add_dependency "oj"
  spec.add_dependency "ox"
  spec.add_dependency "thor"
  spec.add_dependency "inifile"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "terminal-notifier-guard"
end

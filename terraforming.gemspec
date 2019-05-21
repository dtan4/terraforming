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

  spec.add_dependency "aws-sdk-autoscaling", "~> 1"
  spec.add_dependency "aws-sdk-cloudwatch", "~> 1"
  spec.add_dependency "aws-sdk-dynamodb", "~> 1.18"
  spec.add_dependency "aws-sdk-ec2", "~> 1"
  spec.add_dependency "aws-sdk-efs", "~> 1", ">= 1.13.0"
  spec.add_dependency "aws-sdk-elasticache", "~> 1"
  spec.add_dependency "aws-sdk-elasticloadbalancing", "~> 1"
  spec.add_dependency "aws-sdk-elasticloadbalancingv2", "~> 1"
  spec.add_dependency "aws-sdk-iam", "~> 1"
  spec.add_dependency "aws-sdk-kms", "~> 1"
  spec.add_dependency "aws-sdk-rds", "~> 1"
  spec.add_dependency "aws-sdk-redshift", "~> 1"
  spec.add_dependency "aws-sdk-route53", "~> 1"
  spec.add_dependency "aws-sdk-s3", "~> 1"
  spec.add_dependency "aws-sdk-sns", "~> 1"
  spec.add_dependency "aws-sdk-sqs", "~> 1"
  spec.add_dependency "multi_json", "~> 1.12.1"
  spec.add_dependency "thor"

  spec.add_development_dependency "coveralls", "~> 0.8.13"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "simplecov", "~> 0.14.1"
end

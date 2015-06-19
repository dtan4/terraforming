require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'terraforming'

require 'time'

def fixture_path(fixture_name)
  File.join(File.dirname(__FILE__), "fixtures", fixture_name)
end

def tfstate_fixture_path
  fixture_path("terraform.tfstate")
end

def tfstate_fixture
  JSON.parse(open(tfstate_fixture_path).read)
end

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'terraforming'

def fixture_path(fixture_name)
  File.join(File.dirname(__FILE__), "fixtures", fixture_name) << ".json"
end

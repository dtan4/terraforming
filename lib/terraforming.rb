require "erb"
require "json"

require "terraforming/version"

require "terraforming/resource/ec2"
require "terraforming/resource/elb"
require "terraforming/resource/rds"
require "terraforming/resource/s3"
require "terraforming/resource/security_group"
require "terraforming/resource/vpc"

module Terraforming
  def self.template_path(template_name)
    File.join(File.expand_path(File.dirname(__FILE__)), "terraforming", "template", template_name) << ".erb"
  end
end

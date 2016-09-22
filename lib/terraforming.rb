require "oj"

begin
  require "ox"
rescue NameError => e
  spec = Gem::Specification.stubs.find { |s| s.name == 'ox' }
  raise e unless spec
  require File.join(spec.gem_dir, "lib/ox")
end

require "aws-sdk-core"
require 'dogapi'
require "erb"
require "json"
require "thor"
require "zlib"
require "securerandom"

require "terraforming/util"
require "terraforming/version"

require "terraforming/cli"
require "terraforming/resource/auto_scaling_group"
require "terraforming/resource/datadog_monitor"
require "terraforming/resource/db_parameter_group"
require "terraforming/resource/db_security_group"
require "terraforming/resource/db_subnet_group"
require "terraforming/resource/ec2"
require "terraforming/resource/eip"
require "terraforming/resource/elasti_cache_cluster"
require "terraforming/resource/elasti_cache_subnet_group"
require "terraforming/resource/elb"
require "terraforming/resource/iam_group"
require "terraforming/resource/iam_group_membership"
require "terraforming/resource/iam_group_policy"
require "terraforming/resource/iam_instance_profile"
require "terraforming/resource/iam_policy"
require "terraforming/resource/iam_policy_attachment"
require "terraforming/resource/iam_role"
require "terraforming/resource/iam_role_policy"
require "terraforming/resource/iam_user"
require "terraforming/resource/iam_user_policy"
require "terraforming/resource/launch_configuration"
require "terraforming/resource/internet_gateway"
require "terraforming/resource/nat_gateway"
require "terraforming/resource/network_acl"
require "terraforming/resource/network_interface"
require "terraforming/resource/rds"
require "terraforming/resource/redshift"
require "terraforming/resource/route_table"
require "terraforming/resource/route_table_association"
require "terraforming/resource/route53_record"
require "terraforming/resource/route53_zone"
require "terraforming/resource/s3"
require "terraforming/resource/security_group"
require "terraforming/resource/subnet"
require "terraforming/resource/sqs"
require "terraforming/resource/vpc"
require "terraforming/resource/vpn_gateway"

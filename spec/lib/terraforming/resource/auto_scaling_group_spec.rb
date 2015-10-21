require "spec_helper"
require "spec_helper"

module Terraforming
  module Resource
    describe AutoScalingGroup do
      let(:client) do
        Aws::AutoScaling::Client.new(stub_responses: true)
      end

      let(:auto_scaling_groups) do
        [
          {
            auto_scaling_group_name: "hoge",
            auto_scaling_group_arn:
            "arn:aws:autoscaling:ap-northeast-1:123456789012:autoScalingGroup:1234abcd-1dd4-4089-b8c9-12345abcdefg:autoScalingGroupName/hoge",
            launch_configuration_name: "hoge-lc",
            min_size: 1,
            max_size: 4,
            desired_capacity: 2,
            default_cooldown: 300,
            availability_zones: ["ap-northeast-1b"],
            load_balancer_names: [],
            health_check_type: "EC2",
            health_check_grace_period: 300,
            instances: [
              {
                instance_id: "i-1234abcd",
                availability_zone: "ap-northeast-1b",
                lifecycle_state: "InService",
                health_status: "Healthy",
                launch_configuration_name: "hoge-lc"
              },
              {
                instance_id: "i-5678efgh",
                availability_zone: "ap-northeast-1b",
                lifecycle_state: "InService",
                health_status: "Healthy",
                launch_configuration_name: "hoge-lc"
              },
            ],
            created_time: Time.parse("2015-10-21 04:08:39 UTC"),
            suspended_processes: [],
            vpc_zone_identifier: "",
            enabled_metrics: [],
            tags: [
              {
                resource_id: "hoge",
                resource_type: "auto-scaling-group",
                key: "foo",
                value: "bar",
                propagate_at_launch: true,
              }
            ],
            termination_policies: ["Default"],
          },
          {
            auto_scaling_group_name: "fuga",
            auto_scaling_group_arn:
            "arn:aws:autoscaling:ap-northeast-1:123456789012:autoScalingGroup:1234abcd-1dd4-4089-b8c9-12345abcdefg:autoScalingGroupName/fuga",
            launch_configuration_name: "fuga-lc",
            min_size: 1,
            max_size: 4,
            desired_capacity: 2,
            default_cooldown: 300,
            availability_zones: [],
            load_balancer_names: [],
            health_check_type: "EC2",
            health_check_grace_period: 300,
            instances: [
              {
                instance_id: "i-9012ijkl",
                availability_zone: "ap-northeast-1c",
                lifecycle_state: "InService",
                health_status: "Healthy",
                launch_configuration_name: "fuga-lc"
              },
              {
                instance_id: "i-3456mnop",
                availability_zone: "ap-northeast-1c",
                lifecycle_state: "InService",
                health_status: "Healthy",
                launch_configuration_name: "fuga-lc"
              },
            ],
            created_time: Time.parse("2015-10-20 04:08:39 UTC"),
            suspended_processes: [],
            vpc_zone_identifier: "subnet-1234abcd,subnet-5678efgh",
            enabled_metrics: [],
            tags: [],
            termination_policies: ["Default"],
          },
        ]
      end

      before do
        client.stub_responses(:describe_auto_scaling_groups, auto_scaling_groups: auto_scaling_groups)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_autoscaling_group" "hoge" {
    availability_zones        = ["ap-northeast-1b"]
    desired_capacity          = 2
    health_check_grace_period = 300
    health_check_type         = "EC2"
    launch_configuration      = "hoge-lc"
    max_size                  = 4
    min_size                  = 1
    name                      = "hoge"

    tag {
        key   = "foo"
        value = "bar"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_group" "fuga" {
    desired_capacity          = 2
    health_check_grace_period = 300
    health_check_type         = "EC2"
    launch_configuration      = "fuga-lc"
    max_size                  = 4
    min_size                  = 1
    name                      = "fuga"
    vpc_zone_identifier       = ["subnet-1234abcd", "subnet-5678efgh"]

    tag {
    }
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_autoscaling_group.hoge" => {
              "type" => "aws_autoscaling_group",
              "primary" => {
                "id" => "hoge",
                "attributes" => {
                  "availability_zones.#" => "1",
                  "default_cooldown" => "300",
                  "desired_capacity" => "2",
                  "health_check_grace_period" => "300",
                  "health_check_type" => "EC2",
                  "id" => "hoge",
                  "launch_configuration" => "hoge-lc",
                  "load_balancers.#" => "0",
                  "max_size" => "4",
                  "min_size" => "1",
                  "name" => "hoge",
                  "tag.#" => "1",
                  "termination_policies.#" => "0",
                  "vpc_zone_identifier.#" => "0",
                },
                "meta" => {
                  "schema_version" => "1"
                }
              }
            },
            "aws_autoscaling_group.fuga" => {
              "type" => "aws_autoscaling_group",
              "primary" => {
                "id" => "fuga",
                "attributes" => {
                  "availability_zones.#" => "0",
                  "default_cooldown" => "300",
                  "desired_capacity" => "2",
                  "health_check_grace_period" => "300",
                  "health_check_type" => "EC2",
                  "id" => "fuga",
                  "launch_configuration" => "fuga-lc",
                  "load_balancers.#" => "0",
                  "max_size" => "4",
                  "min_size" => "1",
                  "name" => "fuga",
                  "tag.#" => "0",
                  "termination_policies.#" => "0",
                  "vpc_zone_identifier.#" => "2",
                },
                "meta" => {
                  "schema_version" => "1"
                }
              }
            },
          })
        end
      end
    end
  end
end

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
              { key: "Name", value: "hoge" }
            ],
            termination_policies: ["Default"],
          },
          {
            auto_scaling_group_name: "fuga",
            auto_scaling_group_arn:
            "arn:aws:autoscaling:ap-northeast-1:123456789012:autoScalingGroup:1234abcd-1dd4-4089-b8c9-12345abcdefg:autoScalingGroupName/hoge",
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

    tags {
        "Name" = "hoge"
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

    tags {
    }
}

        EOS
        end
      end

      describe ".tfstate" do
        xit "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_instance.hoge" => {
              "type" => "aws_instance",
              "primary" => {
                "id" => "i-1234abcd",
                "attributes" => {
                  "ami" => "ami-1234abcd",
                  "associate_public_ip_address" => "true",
                  "availability_zone" => "ap-northeast-1b",
                  "ebs_block_device.#" => "0",
                  "ebs_optimized" => "false",
                  "ephemeral_block_device.#" => "0",
                  "id" => "i-1234abcd",
                  "instance_type" => "t2.micro",
                  "monitoring" => "false",
                  "private_dns" => "ip-10-0-0-100.ap-northeast-1.compute.internal",
                  "private_ip" => "10.0.0.100",
                  "public_dns" => "ec2-54-12-0-0.ap-northeast-1.compute.amazonaws.com",
                  "public_ip" => "54.12.0.0",
                  "root_block_device.#" => "1",
                  "security_groups.#" => "0",
                  "source_dest_check" => "true",
                  "tenancy" => "default",
                  "vpc_security_group_ids.#" => "1",
                  "subnet_id" => "subnet-1234abcd",
                },
                "meta" => {
                  "schema_version" => "1"
                }
              }
            },
            "aws_instance.i-5678efgh" => {
              "type" => "aws_instance",
              "primary" => {
                "id" => "i-5678efgh",
                "attributes" => {
                  "ami" => "ami-5678efgh",
                  "associate_public_ip_address" => "true",
                  "availability_zone" => "ap-northeast-1b",
                  "ebs_block_device.#" => "1",
                  "ebs_optimized" => "false",
                  "ephemeral_block_device.#" => "0",
                  "id" => "i-5678efgh",
                  "instance_type" => "t2.micro",
                  "monitoring" => "true",
                  "private_dns" => "ip-10-0-0-101.ap-northeast-1.compute.internal",
                  "private_ip" => "10.0.0.101",
                  "public_dns" => "ec2-54-12-0-1.ap-northeast-1.compute.amazonaws.com",
                  "public_ip" => "54.12.0.1",
                  "root_block_device.#" => "0",
                  "security_groups.#" => "1",
                  "source_dest_check" => "true",
                  "tenancy" => "default",
                  "vpc_security_group_ids.#" => "0",
                },
                "meta" => {
                  "schema_version" => "1"
                }
              },
            },
            "aws_instance.i-9012ijkl" => {
              "type" => "aws_instance",
              "primary" => {
                "id" => "i-9012ijkl",
                "attributes" => {
                  "ami" => "ami-9012ijkl",
                  "associate_public_ip_address" => "true",
                  "availability_zone" => "ap-northeast-1b",
                  "ebs_block_device.#" => "0",
                  "ebs_optimized" => "false",
                  "ephemeral_block_device.#" => "0",
                  "id" => "i-9012ijkl",
                  "instance_type" => "t2.micro",
                  "monitoring" => "true",
                  "private_dns" => "ip-10-0-0-102.ap-northeast-1.compute.internal",
                  "private_ip" => "10.0.0.102",
                  "public_dns" => "ec2-54-12-0-2.ap-northeast-1.compute.amazonaws.com",
                  "public_ip" => "54.12.0.2",
                  "root_block_device.#" => "0",
                  "security_groups.#" => "1",
                  "source_dest_check" => "true",
                  "tenancy" => "default",
                  "vpc_security_group_ids.#" => "0",
                },
                "meta" => {
                  "schema_version" => "1"
                }
              },
            }
          })
        end
      end
    end
  end
end

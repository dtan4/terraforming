require "spec_helper"

module Terraforming
  module Resource
    describe LaunchConfiguration do
      let(:client) do
        Aws::AutoScaling::Client.new(stub_responses: true)
      end

      let(:launch_configurations) do
        [
          {
            launch_configuration_name: "launch-123456789",
            launch_configuration_arn: "arn:aws:autoscaling:us-west-2:123456789:launchConfiguration:12345678a-123b-123c-123d-123456789abc:launchConfigurationName/launch-123456789",
            image_id: "ami-1234abcd",
            key_name: "dummy_key",
            security_groups: ["sg-1234abcd"],
            classic_link_vpc_id: nil,
            classic_link_vpc_security_groups: [],
            user_data: "",
            instance_type: "t2.small",
            kernel_id: "",
            ramdisk_id: "",
            block_device_mappings: [
              {
                virtual_name: nil,
                device_name: "/dev/sda1",
                ebs: {
                  snapshot_id: nil,
                  volume_size: 8,
                  volume_type: "standard",
                  delete_on_termination: true,
                  iops: nil,
                  encrypted: nil
                },
                no_device: nil
              }
            ],
            instance_monitoring: {
              enabled: false
            },
            spot_prive: nil,
            iam_instance_profile: nil,
            created_time: Time.parse("2016-03-05 01:23:45 UTC"), #=> Time
            ebs_optimized: false,
            associate_public_ip_address: true,
            placement_tenancy: nil
          },
          {
            launch_configuration_name: "launch-234567891",
            launch_configuration_arn: "arn:aws:autoscaling:us-west-2:123456789:launchConfiguration:12345678a-123b-123c-123d-123456789abc:launchConfigurationName/launch-234567891",
            image_id: "ami-1234abcd",
            key_name: "dummy_key",
            security_groups: ["sg-1234abcd"],
            classic_link_vpc_id: nil,
            classic_link_vpc_security_groups: [],
            user_data: "",
            instance_type: "t2.small",
            kernel_id: "",
            ramdisk_id: "",
            block_device_mappings: [
              {
                virtual_name: nil,
                device_name: "/dev/sda1",
                ebs: {
                  snapshot_id: nil,
                  volume_size: 8,
                  volume_type: "standard",
                  delete_on_termination: true,
                  iops: nil,
                  encrypted: nil
                },
                no_device: nil
              },
              {
                virtual_name: nil,
                device_name: "/dev/sdb",
                ebs: {
                  snapshot_id: nil,
                  volume_size: 8,
                  volume_type: "standard",
                  delete_on_termination: true,
                  iops: nil,
                  encrypted: nil
                },
                no_device: nil
              }
            ],
            instance_monitoring: {
              enabled: false
            },
            spot_prive: nil,
            iam_instance_profile: nil,
            created_time: Time.parse("2016-03-05 01:23:45 UTC"), #=> Time
            ebs_optimized: false,
            associate_public_ip_address: true,
            placement_tenancy: nil
          }
        ]
      end

      before do
        client.stub_responses(
          :describe_launch_configurations,
          launch_configurations: launch_configurations
        )
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_launch_configuration" "launch-123456789" {
    name                        = "launch-123456789"
    image_id                    = "ami-1234abcd"
    instance_type               = "t2.small"
    key_name                    = "dummy_key"
    security_groups             = ["sg-1234abcd"]
    associate_public_ip_address = true
    enable_monitoring           = false
    ebs_optimized               = false

    root_block_device {
        volume_type           = "standard"
        volume_size           = 8
        delete_on_termination = true
    }

}

resource "aws_launch_configuration" "launch-234567891" {
    name                        = "launch-234567891"
    image_id                    = "ami-1234abcd"
    instance_type               = "t2.small"
    key_name                    = "dummy_key"
    security_groups             = ["sg-1234abcd"]
    associate_public_ip_address = true
    enable_monitoring           = false
    ebs_optimized               = false

    root_block_device {
        volume_type           = "standard"
        volume_size           = 8
        delete_on_termination = true
    }

    ebs_block_device {
        device_name           = "/dev/sdb"
        volume_type           = "standard"
        volume_size           = 8
        delete_on_termination = true
    }

}

          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_launch_configuration.launch-123456789" => {
              "type" => "aws_launch_configuration",
              "primary" => {
                "id" => "launch-123456789",
                "attributes" => {
                  "name" => "launch-123456789",
                  "image_id" => "ami-1234abcd",
                  "instance_type" => "t2.small",
                  "key_name" => "dummy_key",
                  "security_groups.#" => "1",
                  "associate_public_ip_address" => "true",
                  "user_data" => "",
                  "enable_monitoring" => "false",
                  "ebs_optimized" => "false",
                  "root_block_device.#" => "1",
                  "ebs_block_device.#" => "0",
                  "ephemeral_block_device.#" => "0",
                  "security_groups.550527283" => "sg-1234abcd"
                }
              }
            },
            "aws_launch_configuration.launch-234567891" => {
              "type" => "aws_launch_configuration",
              "primary" => {
                "id" => "launch-234567891",
                "attributes" => {
                  "name" => "launch-234567891",
                  "image_id" => "ami-1234abcd",
                  "instance_type" => "t2.small",
                  "key_name" => "dummy_key",
                  "security_groups.#" => "1",
                  "associate_public_ip_address" => "true",
                  "user_data" => "",
                  "enable_monitoring" => "false",
                  "ebs_optimized" => "false",
                  "root_block_device.#" => "1",
                  "ebs_block_device.#" => "1",
                  "ephemeral_block_device.#" => "0",
                  "security_groups.550527283" => "sg-1234abcd"
                }
              }
            }
          })
        end
      end
    end
  end
end

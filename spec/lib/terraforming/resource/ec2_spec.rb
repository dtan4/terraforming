require "spec_helper"

module Terraforming
  module Resource
    describe EC2 do
      let(:client) do
        Aws::EC2::Client.new(stub_responses: true)
      end

      let(:instances) do
        [
          {
            instance_id: "i-1234abcd",
            image_id: "ami-1234abcd",
            state: { code: 16, name: "running" },
            private_dns_name: "ip-10-0-0-100.ap-northeast-1.compute.internal",
            public_dns_name: "ec2-54-12-0-0.ap-northeast-1.compute.amazonaws.com",
            state_transition_reason: "",
            key_name: "hoge-key",
            ami_launch_index: 0,
            product_codes: [],
            instance_type: "t2.micro",
            monitoring: { state: "disabled" },
            launch_time: Time.parse("2015-03-12 01:23:45 UTC"),
            placement: { availability_zone: "ap-northeast-1b", group_name: "", tenancy: "default" },
            subnet_id: "subnet-1234abcd",
            vpc_id: "vpc-1234abcd",
            private_ip_address: "10.0.0.100",
            public_ip_address: "54.12.0.0",
            architecture: "x86_64",
            root_device_type: "ebs",
            root_device_name: "/dev/sda1",
            block_device_mappings: [
              {
                device_name: "/dev/sda1",
                ebs: {
                  volume_id: "vol-1234abcd", status: "attached",
                  attach_time: Time.parse("2015-03-12 01:23:45 UTC"), delete_on_termination: true
                }
              }
            ],
            virtualization_type: "hvm",
            client_token: "abcde1234567890123",
            tags: [
              { key: "Name", value: "hoge" }
            ],
            security_groups: [
              { group_name: "default", group_id: "sg-1234abcd" }
            ],
            source_dest_check: true,
            hypervisor: "xen",
            network_interfaces: [
              {
                network_interface_id: "eni-1234abcd",
                subnet_id: "subnet-1234abcd",
                vpc_id: "vpc-1234abcd",
                description: "Primary network interface",
                owner_id: "012345678901",
                status: "in-use",
                mac_address: "01:23:45:67:89:0a",
                private_ip_address: "10.0.0.100",
                private_dns_name: "ip-10-0-0-100.ap-northeast-1.compute.internal",
                source_dest_check: true,
                groups: [
                  { group_name: "default", group_id: "sg-1234abcd" }
                ],
                attachment: {
                  attachment_id: "eni-attach-5678efgh",
                  device_index: 0,
                  status: "attached",
                  attach_time: Time.parse("2015-03-12 01:23:45 UTC"),
                  delete_on_termination: true
                },
                association: {
                  public_ip: "54.12.0.0",
                  public_dns_name: "ec2-54-12-0-0.ap-northeast-1.compute.amazonaws.com",
                  ip_owner_id: "amazon"
                },
                private_ip_addresses: [
                  {
                    private_ip_address: "10.0.0.100",
                    private_dns_name: "ip-10-0-6-100.ap-northeast-1.compute.internal",
                    primary: true,
                    association: {
                      public_ip: "54.12.0.0",
                      public_dns_name: "ec2-54-12-0-0.ap-northeast-1.compute.amazonaws.com",
                      ip_owner_id: "amazon"
                    }
                  }
                ]
              }
            ],
            ebs_optimized: false
          },
          {
            instance_id: "i-5678efgh",
            image_id: "ami-5678efgh",
            state: { code: 16, name: "running" },
            private_dns_name: "ip-10-0-0-101.ap-northeast-1.compute.internal",
            public_dns_name: "ec2-54-12-0-1.ap-northeast-1.compute.amazonaws.com",
            state_transition_reason: "",
            key_name: "hoge-key",
            ami_launch_index: 0,
            product_codes: [],
            instance_type: "t2.micro",
            monitoring: { state: "enabled" },
            launch_time: Time.parse("2015-03-12 01:23:45 UTC"),
            placement: { availability_zone: "ap-northeast-1b", group_name: "pg-1", tenancy: "default" },
            subnet_id: "",
            vpc_id: "vpc-5678efgh",
            private_ip_address: "10.0.0.101",
            public_ip_address: "54.12.0.1",
            architecture: "x86_64",
            root_device_type: "ebs",
            root_device_name: "/dev/sda1",
            block_device_mappings: [
              {
                device_name: "/dev/sda2",
                ebs: {
                  volume_id: "vol-5678efgh", status: "attached",
                  attach_time: Time.parse("2015-03-12 01:23:45 UTC"), delete_on_termination: true
                }
              }
            ],
            virtualization_type: "hvm",
            client_token: "abcde1234567890123",
            tags: [],
            security_groups: [
              { group_name: "default", group_id: "5678efgh" }
            ],
            source_dest_check: true,
            hypervisor: "xen",
            network_interfaces: [
              {
                network_interface_id: "eni-5678efgh",
                subnet_id: "subnet-5678efgh",
                vpc_id: "vpc-5678efgh",
                description: "Primary network interface",
                owner_id: "012345678901",
                status: "in-use",
                mac_address: "01:23:45:67:89:0a",
                private_ip_address: "10.0.0.101",
                private_dns_name: "ip-10-0-0-101.ap-northeast-1.compute.internal",
                source_dest_check: true,
                groups: [
                  { group_name: "default", group_id: "sg-5678efgh" }
                ],
                attachment: {
                  attachment_id: "eni-attach-5678efgh",
                  device_index: 0,
                  status: "attached",
                  attach_time: Time.parse("2015-03-12 01:23:45 UTC"),
                  delete_on_termination: true
                },
                association: {
                  public_ip: "54.12.0.1",
                  public_dns_name: "ec2-54-12-0-1.ap-northeast-1.compute.amazonaws.com",
                  ip_owner_id: "amazon"
                },
                private_ip_addresses: [
                  {
                    private_ip_address: "10.0.0.101",
                    private_dns_name: "ip-10-0-6-101.ap-northeast-1.compute.internal",
                    primary: true,
                    association: {
                      public_ip: "54.12.0.1",
                      public_dns_name: "ec2-54-12-0-1.ap-northeast-1.compute.amazonaws.com",
                      ip_owner_id: "amazon"
                    }
                  }
                ]
              }
            ],
            ebs_optimized: false
          },
          {
            instance_id: "i-9012ijkl",
            image_id: "ami-9012ijkl",
            state: { code: 16, name: "running" },
            private_dns_name: "ip-10-0-0-102.ap-northeast-1.compute.internal",
            public_dns_name: "",
            state_transition_reason: "",
            key_name: "hoge-key",
            ami_launch_index: 0,
            product_codes: [],
            instance_type: "t2.micro",
            monitoring: { state: "pending" },
            launch_time: Time.parse("2015-03-12 01:23:45 UTC"),
            placement: { availability_zone: "ap-northeast-1b", group_name: "", tenancy: "default" },
            subnet_id: "",
            vpc_id: "vpc-9012ijkl",
            private_ip_address: "10.0.0.102",
            public_ip_address: "",
            architecture: "x86_64",
            root_device_type: "ebs",
            root_device_name: "/dev/sda1",
            block_device_mappings: [],
            virtualization_type: "hvm",
            client_token: "abcde1234567890123",
            tags: [],
            security_groups: [
              { group_name: "default", group_id: "9012ijkl" }
            ],
            source_dest_check: true,
            hypervisor: "xen",
            network_interfaces: [
              {
                network_interface_id: "eni-9012ijkl",
                subnet_id: "subnet-9012ijkl",
                vpc_id: "vpc-9012ijkl",
                description: "Primary network interface",
                owner_id: "012345678901",
                status: "in-use",
                mac_address: "01:23:45:67:89:0a",
                private_ip_address: "10.0.0.102",
                private_dns_name: "ip-10-0-0-102.ap-northeast-1.compute.internal",
                source_dest_check: true,
                groups: [
                  { group_name: "default", group_id: "sg-9012ijkl" }
                ],
                attachment: {
                  attachment_id: "eni-attach-9012ijkl",
                  device_index: 0,
                  status: "attached",
                  attach_time: Time.parse("2015-03-12 01:23:45 UTC"),
                  delete_on_termination: true
                },
                association: nil,
                private_ip_addresses: [
                  {
                    private_ip_address: "10.0.0.102",
                    private_dns_name: "ip-10-0-6-102.ap-northeast-1.compute.internal",
                    primary: true,
                    association: nil
                  }
                ]
              }
            ],
            ebs_optimized: false
          }
        ]
      end

      let(:reservations) do
        [
          reservation_id: "r-1234abcd",
          owner_id: "012345678901",
          requester_id: nil,
          groups: [],
          instances: instances
        ]
      end

      let(:hoge_volumes) do
        [
          {
            volume_id: "vol-1234abcd",
            size: 8,
            snapshot_id: "snap-1234abcd",
            availability_zone: "ap-northeast-1c",
            state: "in-use",
            create_time: Time.parse("2015-07-29 15:28:02 UTC"),
            attachments: [
              {
                volume_id: "vol-1234abcd",
                instance_id: "i-1234abcd",
                device: "/dev/sda1",
                state: "attached",
                attach_time: Time.parse("2015-03-12 12:34:56 UTC"),
                delete_on_termination: true
              }
            ],
            volume_type: "io1",
            iops: 24,
            encrypted: false
          }
        ]
      end

      let(:fuga_volumes) do
        [
          {
            volume_id: "vol-5678efgh",
            size: 8,
            snapshot_id: "snap-5678efgh",
            availability_zone: "ap-northeast-1c",
            state: "in-use",
            create_time: Time.parse("2015-07-29 15:28:02 UTC"),
            attachments: [
              {
                volume_id: "vol-5678efgh",
                instance_id: "i-5678efgh",
                device: "/dev/sda2",
                state: "attached",
                attach_time: Time.parse("2015-03-12 12:34:56 UTC"),
                delete_on_termination: true
              }
            ],
            volume_type: "gp2",
            iops: 24,
            encrypted: false
          }
        ]
      end

      before do
        client.stub_responses(:describe_instances, reservations: reservations)
        client.stub_responses(:describe_volumes, [{ volumes: hoge_volumes }, { volumes: fuga_volumes }])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_instance" "hoge" {
    ami                         = "ami-1234abcd"
    availability_zone           = "ap-northeast-1b"
    ebs_optimized               = false
    instance_type               = "t2.micro"
    monitoring                  = false
    key_name                    = "hoge-key"
    subnet_id                   = "subnet-1234abcd"
    vpc_security_group_ids      = ["sg-1234abcd"]
    associate_public_ip_address = true
    private_ip                  = "10.0.0.100"
    source_dest_check           = true

    root_block_device {
        volume_type           = "io1"
        volume_size           = 8
        delete_on_termination = true
        iops                  = 24
    }

    tags {
        "Name" = "hoge"
    }
}

resource "aws_instance" "i-5678efgh" {
    ami                         = "ami-5678efgh"
    availability_zone           = "ap-northeast-1b"
    ebs_optimized               = false
    instance_type               = "t2.micro"
    placement_group             = "pg-1"
    monitoring                  = true
    key_name                    = "hoge-key"
    security_groups             = ["default"]
    associate_public_ip_address = true
    private_ip                  = "10.0.0.101"
    source_dest_check           = true

    ebs_block_device {
        device_name           = "/dev/sda2"
        snapshot_id           = "snap-5678efgh"
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }

    tags {
    }
}

resource "aws_instance" "i-9012ijkl" {
    ami                         = "ami-9012ijkl"
    availability_zone           = "ap-northeast-1b"
    ebs_optimized               = false
    instance_type               = "t2.micro"
    monitoring                  = true
    key_name                    = "hoge-key"
    security_groups             = ["default"]
    associate_public_ip_address = false
    private_ip                  = "10.0.0.102"
    source_dest_check           = true

    tags {
    }
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
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
                  "placement_group" => "pg-1",
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
                  "associate_public_ip_address" => "false",
                  "availability_zone" => "ap-northeast-1b",
                  "ebs_block_device.#" => "0",
                  "ebs_optimized" => "false",
                  "ephemeral_block_device.#" => "0",
                  "id" => "i-9012ijkl",
                  "instance_type" => "t2.micro",
                  "monitoring" => "true",
                  "private_dns" => "ip-10-0-0-102.ap-northeast-1.compute.internal",
                  "private_ip" => "10.0.0.102",
                  "public_dns" => "",
                  "public_ip" => "",
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

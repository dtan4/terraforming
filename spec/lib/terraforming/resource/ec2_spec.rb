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
            launch_time: Time.parse("2015-03-12 01:23:45 UTC"),
            placement: { availability_zone: "ap-northeast-1b", group_name: "", tenancy: "default" },
            monitoring: { state: "disabled" },
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
            launch_time: Time.parse("2015-03-12 01:23:45 UTC"),
            placement: { availability_zone: "ap-northeast-1b", group_name: "", tenancy: "default" },
            monitoring: { state: "disabled" },
            subnet_id: "",
            vpc_id: "vpc-5678efgh",
            private_ip_address: "10.0.0.101",
            public_ip_address: "54.12.0.1",
            architecture: "x86_64",
            root_device_type: "ebs",
            root_device_name: "/dev/sda1",
            block_device_mappings: [
              {
                device_name: "/dev/sda1",
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

      before do
        client.stub_responses(:describe_instances, reservations: reservations)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_instance" "hoge" {
    ami                         = "ami-1234abcd"
    availability_zone           = "ap-northeast-1b"
    ebs_optimized               = false
    instance_type               = "t2.micro"
    key_name                    = "hoge-key"
    subnet_id                   = "subnet-1234abcd"
    vpc_security_group_ids      = ["sg-1234abcd"]
    associate_public_ip_address = true
    private_ip                  = "10.0.0.100"
    source_dest_check           = true

    ebs_block_device {
        device_name = "/dev/sda1"
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
    key_name                    = "hoge-key"
    security_groups             = ["default"]
    associate_public_ip_address = true
    private_ip                  = "10.0.0.101"
    source_dest_check           = true

    ebs_block_device {
        device_name = "/dev/sda1"
    }

    tags {
    }
}

        EOS
        end
      end

      describe ".tfstate" do
        context "without existing tfstate" do
          it "should generate tfstate" do
            expect(described_class.tfstate(client: client)).to eq JSON.pretty_generate({
              "version" => 1,
              "serial" => 1,
              "modules" => [
                {
                  "path" => [
                    "root"
                  ],
                  "outputs" => {},
                  "resources" => {
                    "aws_instance.hoge"=> {
                      "type"=> "aws_instance",
                      "primary"=> {
                        "id"=> "i-1234abcd",
                        "attributes"=> {
                          "ami"=> "ami-1234abcd",
                          "associate_public_ip_address"=> "true",
                          "availability_zone"=> "ap-northeast-1b",
                          "ebs_block_device.#"=> "1",
                          "ebs_optimized"=> "false",
                          "ephemeral_block_device.#"=> "0",
                          "id"=> "i-1234abcd",
                          "instance_type"=> "t2.micro",
                          "private_dns"=> "ip-10-0-0-100.ap-northeast-1.compute.internal",
                          "private_ip"=> "10.0.0.100",
                          "public_dns"=> "ec2-54-12-0-0.ap-northeast-1.compute.amazonaws.com",
                          "public_ip"=> "54.12.0.0",
                          "root_block_device.#"=> "1",
                          "security_groups.#"=> "0",
                          "source_dest_check"=> "true",
                          "tenancy"=> "default",
                          "vpc_security_group_ids.#"=> "1",
                          "subnet_id"=> "subnet-1234abcd",
                        },
                        "meta"=> {
                          "schema_version"=> "1"
                        }
                      }
                    },
                    "aws_instance.i-5678efgh"=> {
                      "type"=> "aws_instance",
                      "primary"=> {
                        "id"=> "i-5678efgh",
                        "attributes"=> {
                          "ami"=> "ami-5678efgh",
                          "associate_public_ip_address"=> "true",
                          "availability_zone"=> "ap-northeast-1b",
                          "ebs_block_device.#"=> "1",
                          "ebs_optimized"=> "false",
                          "ephemeral_block_device.#"=> "0",
                          "id"=> "i-5678efgh",
                          "instance_type"=> "t2.micro",
                          "private_dns"=> "ip-10-0-0-101.ap-northeast-1.compute.internal",
                          "private_ip"=> "10.0.0.101",
                          "public_dns"=> "ec2-54-12-0-1.ap-northeast-1.compute.amazonaws.com",
                          "public_ip"=> "54.12.0.1",
                          "root_block_device.#"=> "1",
                          "security_groups.#"=> "1",
                          "source_dest_check"=> "true",
                          "tenancy"=> "default",
                          "vpc_security_group_ids.#"=> "0",
                        },
                        "meta"=> {
                          "schema_version"=> "1"
                        }
                      }
                    }
                  }
                }
              ]
            })
          end
        end

        context "with existing tfstate" do
          it "should generate tfstate and merge it to existing tfstate" do
            expect(described_class.tfstate(client: client, tfstate_base: tfstate_fixture)).to eq JSON.pretty_generate({
              "version" => 1,
              "serial" => 89,
              "remote" => {
                "type" => "s3",
                "config" => { "bucket" => "terraforming-tfstate", "key" => "tf" }
              },
              "modules" => [
                {
                  "path" => ["root"],
                  "outputs" => {},
                  "resources" => {
                    "aws_elb.hogehoge" => {
                      "type" => "aws_elb",
                      "primary" => {
                        "id" => "hogehoge",
                        "attributes" => {
                          "availability_zones.#" => "2",
                          "connection_draining" => "true",
                          "connection_draining_timeout" => "300",
                          "cross_zone_load_balancing" => "true",
                          "dns_name" => "hoge-12345678.ap-northeast-1.elb.amazonaws.com",
                          "health_check.#" => "1",
                          "id" => "hogehoge",
                          "idle_timeout" => "60",
                          "instances.#" => "1",
                          "listener.#" => "1",
                          "name" => "hoge",
                          "security_groups.#" => "2",
                          "source_security_group" => "default",
                          "subnets.#" => "2"
                        }
                      }
                    },
                    "aws_instance.hoge"=> {
                      "type"=> "aws_instance",
                      "primary"=> {
                        "id"=> "i-1234abcd",
                        "attributes"=> {
                          "ami"=> "ami-1234abcd",
                          "associate_public_ip_address"=> "true",
                          "availability_zone"=> "ap-northeast-1b",
                          "ebs_block_device.#"=> "1",
                          "ebs_optimized"=> "false",
                          "ephemeral_block_device.#"=> "0",
                          "id"=> "i-1234abcd",
                          "instance_type"=> "t2.micro",
                          "private_dns"=> "ip-10-0-0-100.ap-northeast-1.compute.internal",
                          "private_ip"=> "10.0.0.100",
                          "public_dns"=> "ec2-54-12-0-0.ap-northeast-1.compute.amazonaws.com",
                          "public_ip"=> "54.12.0.0",
                          "root_block_device.#"=> "1",
                          "security_groups.#"=> "0",
                          "source_dest_check"=> "true",
                          "tenancy"=> "default",
                          "vpc_security_group_ids.#"=> "1",
                          "subnet_id"=> "subnet-1234abcd",
                        },
                        "meta"=> {
                          "schema_version"=> "1"
                        }
                      }
                    },
                    "aws_instance.i-5678efgh"=> {
                      "type"=> "aws_instance",
                      "primary"=> {
                        "id"=> "i-5678efgh",
                        "attributes"=> {
                          "ami"=> "ami-5678efgh",
                          "associate_public_ip_address"=> "true",
                          "availability_zone"=> "ap-northeast-1b",
                          "ebs_block_device.#"=> "1",
                          "ebs_optimized"=> "false",
                          "ephemeral_block_device.#"=> "0",
                          "id"=> "i-5678efgh",
                          "instance_type"=> "t2.micro",
                          "private_dns"=> "ip-10-0-0-101.ap-northeast-1.compute.internal",
                          "private_ip"=> "10.0.0.101",
                          "public_dns"=> "ec2-54-12-0-1.ap-northeast-1.compute.amazonaws.com",
                          "public_ip"=> "54.12.0.1",
                          "root_block_device.#"=> "1",
                          "security_groups.#"=> "1",
                          "source_dest_check"=> "true",
                          "tenancy"=> "default",
                          "vpc_security_group_ids.#"=> "0",
                        },
                        "meta"=> {
                          "schema_version"=> "1"
                        }
                      }
                    }
                  }
                }
              ]
            })
          end
        end
      end
    end
  end
end

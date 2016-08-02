require "spec_helper"

module Terraforming
  module Resource
    describe NetworkInterface do
      let(:client) do
        Aws::EC2::Client.new(stub_responses: true)
      end

      let(:network_interfaces) do
        [
          {
            status: "available",
            mac_address: "11:11:11:11:11:11",
            source_dest_check: true,
            vpc_id: "vpc-12345678",
            description: "test network_interface",
            network_interface_id: "eni-1234abcd",
            private_ip_addresses: [
              {
                private_dns_name: "ip-1-1-1-1.ap-northeast-1.compute.internal",
                private_ip_address: "1.1.1.1",
                primary: true
              }
            ],
            requester_managed: false,
            groups: [
            ],
            private_dns_name: "ip-1-1-1-1.ap-northeast-1.compute.internal",
            availability_zone: "ap-northeast-1a",
            requester_id: "234567890123",
            subnet_id: "subnet-1234abcd",
            owner_id: "123456789012",
            private_ip_address: "1.1.1.1",
          },
          {
            status: "in-use",
            mac_address: "22:22:22:22:22:22",
            source_dest_check: false,
            vpc_id: "vpc-12345678",
            description: "test network_interface",
            association: {
              public_ip: "9.9.9.9",
              association_id: "eipassoc-63446006",
              public_dns_name: "ec2-9-9-9-9.ap-northeast-1.compute.amazonaws.com",
              allocation_id: "eipalloc-7fe93c1a",
              ip_owner_id: "123456789012"
            },
            network_interface_id: "eni-2345efgh",
            private_ip_addresses: [
              {
                private_dns_name: "ip-2-2-2-2.ap-northeast-1.compute.internal",
                association: {
                  public_ip: "9.9.9.9",
                  association_id: "eipassoc-63446006",
                  public_dns_name: "ec2-9-9-9-9.ap-northeast-1.compute.amazonaws.com",
                  allocation_id: "eipalloc-7fe93c1a",
                  ip_owner_id: "123456789012"
                },
                private_ip_address: "2.2.2.2",
                primary: true
              },
              {
                private_dns_name: "ip-3-3-3-3.ap-northeast-1.compute.internal",
                private_ip_address: "3.3.3.3",
                primary: false
              },
            ],
            requester_managed: false,
            groups: [
              {
                group_name: "test",
                group_id: "sg-12345678",
              },
              {
                group_name: "test2",
                group_id: "sg-23456789",
              }
            ],
            attachment: {
              status: "attached",
              device_index: 0,
              attach_time: Time.parse("2015-04-01 12:34:56 UTC"),
              instance_id: "i-12345678",
              delete_on_termination: true,
              attachment_id: "eni-attach-12345678",
              instance_owner_id: "345678901234",
            },
            private_dns_name: "ip-2-2-2-2.ap-northeast-1.compute.internal",
            availability_zone: "ap-northeast-1a",
            requester_id: "234567890123",
            subnet_id: "subnet-1234abcd",
            owner_id: "123456789012",
            private_ip_address: "2.2.2.2",
            tag_set: [
              { key: "Name", value: "fuga" },
            ]
          }
        ]
      end

      before do
        client.stub_responses(:describe_network_interfaces, network_interfaces: network_interfaces)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_network_interface" "eni-1234abcd" {
    subnet_id         = "subnet-1234abcd"
    private_ips       = ["1.1.1.1"]
    security_groups   = []
    source_dest_check = true
}

resource "aws_network_interface" "eni-2345efgh" {
    subnet_id         = "subnet-1234abcd"
    private_ips       = ["2.2.2.2", "3.3.3.3"]
    security_groups   = ["sg-12345678", "sg-23456789"]
    source_dest_check = false
    attachment {
        instance     = "i-12345678"
        device_index = 0
    }
    tags {
        "Name" = "fuga"
    }
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_network_interface.eni-1234abcd" => {
              "type" => "aws_network_interface",
              "primary" => {
                "id" => "eni-1234abcd",
                "attributes" => {
                  "attachment.#" => "0",
                  "id" => "eni-1234abcd",
                  "private_ips.#" => "1",
                  "security_groups.#" => "0",
                  "source_dest_check" => "true",
                  "subnet_id" => "subnet-1234abcd",
                  "tags.#" => "0",
                }
              }
            },
            "aws_network_interface.eni-2345efgh" => {
              "type" => "aws_network_interface",
              "primary" => {
                "id" => "eni-2345efgh",
                "attributes" => {
                  "attachment.#" => "1",
                  "id" => "eni-2345efgh",
                  "private_ips.#" => "2",
                  "security_groups.#" => "2",
                  "source_dest_check" => "false",
                  "subnet_id" => "subnet-1234abcd",
                  "tags.#" => "1",
                }
              }
            },
          })
        end
      end
    end
  end
end

require "spec_helper"

module Terraforming
  module Resource
    describe EIP do
      let(:client) do
        Aws::EC2::Client.new(stub_responses: true)
      end

      let(:eips) do
        [
          {
            domain: "vpc",
            instance_id: "i-12345678",
            network_interface_id: "eni-12345678",
            association_id: "eipassoc-98765432",
            network_interface_owner_id: "123456789012",
            public_ip: "12.34.56.78",
            allocation_id: "eipalloc-87654321",
            private_ip_address: "1.1.1.1",
          },
          {
            domain: "vpc",
            network_interface_id: "eni-23456789",
            association_id: "eipassoc-87654321",
            network_interface_owner_id: "234567890123",
            public_ip: "2.2.2.2",
            allocation_id: "eipalloc-76543210",
            private_ip_address: "9.9.9.9",
          },
          {
            public_ip: "3.3.3.3",
            domain: "vpc",
            allocation_id: "eipalloc-33333333",
          },
          {
            instance_id: "i-91112221",
            public_ip: "2.2.2.4",
            allocation_id: nil,
            association_id: nil,
            domain: "standard",
            network_interface_id: nil,
            network_interface_owner_id: nil,
            private_ip_address: nil
          }
        ]
      end

      before do
        client.stub_responses(:describe_addresses, addresses: eips)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_eip" "eipalloc-87654321" {
    instance          = "i-12345678"
    vpc               = true
}

resource "aws_eip" "eipalloc-76543210" {
    network_interface = "eni-23456789"
    vpc               = true
}

resource "aws_eip" "eipalloc-33333333" {
    vpc               = true
}

resource "aws_eip" "2-2-2-4" {
    instance          = "i-91112221"
    vpc               = false
}

          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_eip.eipalloc-87654321" => {
              "type" => "aws_eip",
              "primary" => {
                "id" => "eipalloc-87654321",
                "attributes" => {
                    "association_id" => "eipassoc-98765432",
                    "domain" => "vpc",
                    "id" => "eipalloc-87654321",
                    "instance" => "i-12345678",
                    "network_interface" => "eni-12345678",
                    "private_ip" => "1.1.1.1",
                    "public_ip" => "12.34.56.78",
                    "vpc" => "true"
                }
              }
            },
            "aws_eip.eipalloc-76543210" => {
              "type" => "aws_eip",
              "primary" => {
                "id" => "eipalloc-76543210",
                "attributes" => {
                    "association_id" => "eipassoc-87654321",
                    "domain" => "vpc",
                    "id" => "eipalloc-76543210",
                    "network_interface" => "eni-23456789",
                    "private_ip" => "9.9.9.9",
                    "public_ip" => "2.2.2.2",
                    "vpc" => "true"
                }
              }
            },
            "aws_eip.eipalloc-33333333" => {
              "type" => "aws_eip",
              "primary" => {
                "id" => "eipalloc-33333333",
                "attributes" => {
                    "domain" => "vpc",
                    "id" => "eipalloc-33333333",
                    "public_ip" => "3.3.3.3",
                    "vpc" => "true"
                }
              }
            },
            "aws_eip.2-2-2-4" => {
              "type" => "aws_eip",
              "primary" => {
                "id" => "2.2.2.4",
                "attributes" => {
                    "domain" => "standard",
                    "id" => "2.2.2.4",
                    "instance" => "i-91112221",
                    "public_ip" => "2.2.2.4",
                    "vpc" => "false"
                },
              },
            },
          })
        end
      end
    end
  end
end

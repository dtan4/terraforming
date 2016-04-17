require "spec_helper"

module Terraforming
  module Resource
    describe VPNGateway do
      let(:client) do
        Aws::EC2::Client.new(stub_responses: true)
      end

      let(:vpn_gateways) do
        [
          {
            vpn_gateway_id: "vgw-1234abcd",
            vpc_attachments: [
              vpc_id: "vpc-1234abcd",
              state: "available"
            ],
            availability_zone: "us-east-1c",
            tags: [],
          },
          {
            vpn_gateway_id: "vgw-5678efgh",
            vpc_attachments: [
              vpc_id: "vpc-5678efgh",
              state: "available"
            ],
            availability_zone: "us-east-1d",
            tags: [
              {
                key: "Name",
                value: "test"
              }
            ]
          }
        ]
      end

      before do
        client.stub_responses(:describe_vpn_gateways, vpn_gateways: vpn_gateways)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_vpn_gateway" "vgw-1234abcd" {
    vpc_id = "vpc-1234abcd"
    availability_zone = "us-east-1c"
    tags {
    }
}

resource "aws_vpn_gateway" "test" {
    vpc_id = "vpc-5678efgh"
    availability_zone = "us-east-1d"
    tags {
        "Name" = "test"
    }
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_vpn_gateway.vgw-1234abcd" => {
              "type" => "aws_vpn_gateway",
              "primary" => {
                "id" => "vgw-1234abcd",
                "attributes" => {
                  "id"     => "vgw-1234abcd",
                  "vpc_id" => "vpc-1234abcd",
                  "availability_zone" => "us-east-1c",
                  "tags.#" => "0",
                }
              }
            },
            "aws_vpn_gateway.test" => {
              "type" => "aws_vpn_gateway",
              "primary" => {
                "id" => "vgw-5678efgh",
                "attributes" => {
                  "id"     => "vgw-5678efgh",
                  "vpc_id" => "vpc-5678efgh",
                  "availability_zone" => "us-east-1d",
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

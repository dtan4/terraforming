require "spec_helper"

module Terraforming
  module Resource
    describe NATGateway do
      let(:client) do
        Aws::EC2::Client.new(stub_responses: true)
      end

      let(:nat_gateways) do
        [
          {
            nat_gateway_id: "nat-0c5b68b2c4d64e037",
            subnet_id: "subnet-cd5645f7",
            nat_gateway_addresses: [
              allocation_id: "eipalloc-b02a3c79",
              network_interface_id: "eni-03d4046f",
              private_ip: "10.0.3.6",
              public_ip: "52.5.3.67",
            ]
          },
          {
            nat_gateway_id: "nat-0c5b68b2c4d64ea12",
            subnet_id: "subnet-cd564c9e",
            nat_gateway_addresses: [
              allocation_id: "eipalloc-a03a3c79",
              network_interface_id: "eni-b6e4046f",
              private_ip: "10.0.4.6",
              public_ip: "54.4.5.68",
            ]
          }
        ]
      end

      before do
        client.stub_responses(:describe_nat_gateways, nat_gateways: nat_gateways)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_nat_gateway" "nat-0c5b68b2c4d64e037" {
    allocation_id = "eipalloc-b02a3c79"
    subnet_id = "subnet-cd5645f7"
}

resource "aws_nat_gateway" "nat-0c5b68b2c4d64ea12" {
    allocation_id = "eipalloc-a03a3c79"
    subnet_id = "subnet-cd564c9e"
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_nat_gateway.nat-0c5b68b2c4d64e037" => {
              "type" => "aws_nat_gateway",
              "primary" => {
                "id" => "nat-0c5b68b2c4d64e037",
                "attributes" => {
                  "id" => "nat-0c5b68b2c4d64e037",
                  "allocation_id" => "eipalloc-b02a3c79",
                  "subnet_id" => "subnet-cd5645f7",
                  "network_inferface_id" => "eni-03d4046f",
                  "private_ip" => "10.0.3.6",
                  "public_ip" => "52.5.3.67",
                }
              }
            },
            "aws_nat_gateway.nat-0c5b68b2c4d64ea12" => {
              "type" => "aws_nat_gateway",
              "primary" => {
                "id" => "nat-0c5b68b2c4d64ea12",
                "attributes" => {
                  "id" => "nat-0c5b68b2c4d64ea12",
                  "allocation_id" => "eipalloc-a03a3c79",
                  "subnet_id" => "subnet-cd564c9e",
                  "network_inferface_id" => "eni-b6e4046f",
                  "private_ip" => "10.0.4.6",
                  "public_ip" => "54.4.5.68",
                }
              }
            },
          })
        end
      end
    end
  end
end

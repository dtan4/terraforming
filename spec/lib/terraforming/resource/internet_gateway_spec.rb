require "spec_helper"

module Terraforming
  module Resource
    describe InternetGateway do
      let(:client) do
        Aws::EC2::Client.new(stub_responses: true)
      end

      let(:internet_gateways) do
        [
          {
            internet_gateway_id: "igw-1234abcd",
            attachments: [
              vpc_id: "vpc-1234abcd",
              state: "available"
            ],
            tags: [],
          },
          {
            internet_gateway_id: "igw-5678efgh",
            attachments: [
              vpc_id: "vpc-5678efgh",
              state: "available"
            ],
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
        client.stub_responses(:describe_internet_gateways, internet_gateways: internet_gateways)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_internet_gateway" "igw-1234abcd" {
    vpc_id = "vpc-1234abcd"

    tags {
    }
}

resource "aws_internet_gateway" "test" {
    vpc_id = "vpc-5678efgh"

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
            "aws_internet_gateway.igw-1234abcd" => {
              "type" => "aws_internet_gateway",
              "primary" => {
                "id" => "igw-1234abcd",
                "attributes" => {
                  "id"     => "igw-1234abcd",
                  "vpc_id" => "vpc-1234abcd",
                  "tags.#" => "0",
                }
              }
            },
            "aws_internet_gateway.test" => {
              "type" => "aws_internet_gateway",
              "primary" => {
                "id" => "igw-5678efgh",
                "attributes" => {
                  "id"     => "igw-5678efgh",
                  "vpc_id" => "vpc-5678efgh",
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

require "spec_helper"

module Terraforming
  module Resource
    describe Subnet do
      let(:client) do
        Aws::EC2::Client.new(stub_responses: true)
      end

      let(:subnets) do
        [
          {
            subnet_id: "subnet-1234abcd",
            state: "available",
            vpc_id: "vpc-1234abcd",
            cidr_block: "10.0.8.0/21",
            available_ip_address_count: 1000,
            availability_zone: "ap-northeast-1c",
            default_for_az: false,
            map_public_ip_on_launch: false,
            tags: [
              { key: "Name", value: "hoge" }
            ]
          },
          {
            subnet_id: "subnet-5678efgh",
            state: "available",
            vpc_id: "vpc-5678efgh",
            cidr_block: "10.0.8.0/21",
            available_ip_address_count: 2000,
            availability_zone: "ap-northeast-1c",
            default_for_az: false,
            map_public_ip_on_launch: false,
            tags: [
              { key: "Name", value: "fuga" }
            ]
          }
        ]
      end

      before do
        client.stub_responses(:describe_subnets, subnets: subnets)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_subnet" "subnet-1234abcd-hoge" {
    vpc_id                  = "vpc-1234abcd"
    cidr_block              = "10.0.8.0/21"
    availability_zone       = "ap-northeast-1c"
    map_public_ip_on_launch = false

    tags {
        "Name" = "hoge"
    }
}

resource "aws_subnet" "subnet-5678efgh-fuga" {
    vpc_id                  = "vpc-5678efgh"
    cidr_block              = "10.0.8.0/21"
    availability_zone       = "ap-northeast-1c"
    map_public_ip_on_launch = false

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
            "aws_subnet.subnet-1234abcd-hoge" => {
              "type" => "aws_subnet",
              "primary" => {
                "id" => "subnet-1234abcd",
                "attributes" => {
                  "availability_zone" => "ap-northeast-1c",
                  "cidr_block" => "10.0.8.0/21",
                  "id" => "subnet-1234abcd",
                  "map_public_ip_on_launch" => "false",
                  "tags.#" => "1",
                  "vpc_id" => "vpc-1234abcd"
                }
              }
            },
            "aws_subnet.subnet-5678efgh-fuga" => {
              "type" => "aws_subnet",
              "primary" => {
                "id" => "subnet-5678efgh",
                "attributes" => {
                  "availability_zone" => "ap-northeast-1c",
                  "cidr_block" => "10.0.8.0/21",
                  "id" => "subnet-5678efgh",
                  "map_public_ip_on_launch" => "false",
                  "tags.#" => "1",
                  "vpc_id" => "vpc-5678efgh"
                }
              }
            },
          })
        end
      end
    end
  end
end

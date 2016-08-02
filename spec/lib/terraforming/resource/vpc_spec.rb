require "spec_helper"

module Terraforming
  module Resource
    describe VPC do
      let(:client) do
        Aws::EC2::Client.new(stub_responses: true)
      end

      let(:vpcs) do
        [
          {
            vpc_id: "vpc-1234abcd",
            state: "available",
            cidr_block: "10.0.0.0/16",
            dhcp_options_id: "dopt-1234abcd",
            tags: [
              {
                key: "Name",
                value: "hoge"
              }
            ],
            instance_tenancy: "default",
            is_default: false
          },
          {
            vpc_id: "vpc-5678efgh",
            state: "available",
            cidr_block: "10.0.0.0/16",
            dhcp_options_id: "dopt-5678efgh",
            tags: [
              {
                key: "Name",
                value: "fuga"
              }
            ],
            instance_tenancy: "default",
            is_default: false
          }
        ]
      end

      before do
        client.stub_responses(:describe_vpcs, vpcs: vpcs)

        attr_stub_responses = []

        %w(vpc-1234abcd vpc-5678efgh).each do |_vpc_id|
          %i(enable_dns_hostnames enable_dns_support).each do |attr|
            attr_stub_responses << { attr => { value: true }  }
          end
        end

        client.stub_responses(:describe_vpc_attribute, attr_stub_responses)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_vpc" "hoge" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
        "Name" = "hoge"
    }
}

resource "aws_vpc" "fuga" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

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
            "aws_vpc.hoge" => {
              "type" => "aws_vpc",
              "primary" => {
                "id" => "vpc-1234abcd",
                "attributes" => {
                  "cidr_block" => "10.0.0.0/16",
                  "enable_dns_hostnames" => "true",
                  "enable_dns_support" => "true",
                  "id" => "vpc-1234abcd",
                  "instance_tenancy" => "default",
                  "tags.#" => "1",
                }
              }
            },
            "aws_vpc.fuga" => {
              "type" => "aws_vpc",
              "primary" => {
                "id" => "vpc-5678efgh",
                "attributes" => {
                  "cidr_block" => "10.0.0.0/16",
                  "enable_dns_hostnames" => "true",
                  "enable_dns_support" => "true",
                  "id" => "vpc-5678efgh",
                  "instance_tenancy" => "default",
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

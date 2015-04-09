require "spec_helper"

module Terraforming::Resource
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
    end

    describe ".tf" do
      it "should generate tf" do
        expect(described_class.tf(client)).to eq <<-EOS
resource "aws_vpc" "hoge" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"

    tags {
        Name = "hoge"
    }
}

resource "aws_vpc" "fuga" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"

    tags {
        Name = "fuga"
    }
}

        EOS
      end
    end

    describe ".tfstate" do
      it "should generate tfstate" do
        expect(described_class.tfstate(client)).to eq JSON.pretty_generate({
          "version" => 1,
          "serial" => 84,
          "modules" => {
            "path" => [
              "root"
            ],
            "outputs" => {},
            "resources" => {
              "aws_vpc.hoge" => {
                "type" => "aws_vpc",
                "primary" => {
                  "id" => "vpc-1234abcd",
                  "attributes" => {
                    "cidr_block" => "10.0.0.0/16",
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
                    "id" => "vpc-5678efgh",
                    "instance_tenancy" => "default",
                    "tags.#" => "1",
                  }
                }
              }
            }
          }
        })
      end
    end
  end
end

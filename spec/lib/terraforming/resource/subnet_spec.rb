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
resource "aws_subnet" "hoge" {
    vpc_id                  = "vpc-1234abcd"
    cidr_block              = "10.0.8.0/21"
    availability_zone       = "ap-northeast-1c"
    map_public_ip_on_launch = false

    tags {
        "Name" = "hoge"
    }
}

resource "aws_subnet" "fuga" {
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
                    "aws_subnet.hoge" => {
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
                    "aws_subnet.fuga" => {
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
              "serial" => 88,
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
                    "aws_subnet.hoge" => {
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
                    "aws_subnet.fuga" => {
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

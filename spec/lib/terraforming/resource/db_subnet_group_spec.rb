require "spec_helper"

module Terraforming
  module Resource
    describe DBSubnetGroup do
      let(:client) do
        Aws::RDS::Client.new(stub_responses: true)
      end

      let(:db_subnet_groups) do
        [
          {
            subnets: [
              {
                subnet_status: "Active",
                subnet_identifier: "subnet-1234abcd",
                subnet_availability_zone: {
                  name: "ap-northeast-1c"
                }
              },
              {
                subnet_status: "Active",
                subnet_identifier: "subnet-5678efgh",
                subnet_availability_zone: {
                  name: "ap-northeast-1b"
                }
              }
            ],
            db_subnet_group_name: "hoge",
            vpc_id: "vpc-1234abcd",
            db_subnet_group_description: "DB subnet group hoge",
            subnet_group_status: "Complete"
          },
          {
            subnets: [
              {
                subnet_status: "Active",
                subnet_identifier: "subnet-9012ijkl",
                subnet_availability_zone: {
                  name: "ap-northeast-1b"
                }
              },
              {
                subnet_status: "Active",
                subnet_identifier: "subnet-3456mnop",
                subnet_availability_zone: {
                  name: "ap-northeast-1c"
                }
              }
            ],
            db_subnet_group_name: "fuga",
            vpc_id: "vpc-5678efgh",
            db_subnet_group_description: "DB subnet group fuga",
            subnet_group_status: "Complete"
          }
        ]
      end

      before do
        client.stub_responses(:describe_db_subnet_groups, db_subnet_groups: db_subnet_groups)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_db_subnet_group" "hoge" {
    name        = "hoge"
    description = "DB subnet group hoge"
    subnet_ids  = ["subnet-1234abcd", "subnet-5678efgh"]
}

resource "aws_db_subnet_group" "fuga" {
    name        = "fuga"
    description = "DB subnet group fuga"
    subnet_ids  = ["subnet-9012ijkl", "subnet-3456mnop"]
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
                    "aws_db_subnet_group.hoge" => {
                      "type" => "aws_db_subnet_group",
                      "primary" => {
                        "id" => "hoge",
                        "attributes" => {
                          "description" => "DB subnet group hoge",
                          "name" => "hoge",
                          "subnet_ids.#" => "2",
                        }
                      }
                    },
                    "aws_db_subnet_group.fuga" => {
                      "type" => "aws_db_subnet_group",
                      "primary" => {
                        "id" => "fuga",
                        "attributes" => {
                          "description" => "DB subnet group fuga",
                          "name" => "fuga",
                          "subnet_ids.#" => "2",
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
                    "aws_db_subnet_group.hoge" => {
                      "type" => "aws_db_subnet_group",
                      "primary" => {
                        "id" => "hoge",
                        "attributes" => {
                          "description" => "DB subnet group hoge",
                          "name" => "hoge",
                          "subnet_ids.#" => "2",
                        }
                      }
                    },
                    "aws_db_subnet_group.fuga" => {
                      "type" => "aws_db_subnet_group",
                      "primary" => {
                        "id" => "fuga",
                        "attributes" => {
                          "description" => "DB subnet group fuga",
                          "name" => "fuga",
                          "subnet_ids.#" => "2",
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

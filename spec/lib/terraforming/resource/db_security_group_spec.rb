require "spec_helper"

module Terraforming
  module Resource
    describe DBSecurityGroup do
      let(:client) do
        Aws::RDS::Client.new(stub_responses: true)
      end

      let(:db_security_groups) do
        [
          {
            ip_ranges: [],
            owner_id: "123456789012",
            db_security_group_description: "default",
            ec2_security_groups: [
              {
                status: "authorized",
                ec2_security_group_name: "default",
                ec2_security_group_owner_id: "123456789012",
                ec2_security_group_id: "sg-1234abcd"
              }
            ],
            db_security_group_name: "default"
          },
          {
            ip_ranges: [
              {
                status: "authorized",
                cidrip: "0.0.0.0/0"
              }
            ],
            owner_id: "3456789012",
            db_security_group_description: "foobar group",
            ec2_security_groups: [
              {
                status: "authorized",
                ec2_security_group_name: "foobar",
                ec2_security_group_owner_id: "3456789012",
                ec2_security_group_id: "sg-5678efgh"
              }
            ],
            db_security_group_name: "sgfoobar"
          }
        ]
      end

      before do
        client.stub_responses(:describe_db_security_groups, db_security_groups: db_security_groups)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_db_security_group" "default" {
    name        = "default"
    description = "default"

    ingress {
        cidr                    = ""
        security_group_name     = "default"
        security_group_id       = "sg-1234abcd"
        security_group_owner_id = "123456789012"
    }

}

resource "aws_db_security_group" "sgfoobar" {
    name        = "sgfoobar"
    description = "foobar group"

    ingress {
        cidr                    = "0.0.0.0/0"
        security_group_name     = ""
        security_group_id       = ""
        security_group_owner_id = ""
    }

    ingress {
        cidr                    = ""
        security_group_name     = "foobar"
        security_group_id       = "sg-5678efgh"
        security_group_owner_id = "3456789012"
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
                    "aws_db_security_group.default" => {
                      "type" => "aws_db_security_group",
                      "primary" => {
                        "id" => "default",
                        "attributes" => {
                          "db_subnet_group_name" => "default",
                          "id" => "default",
                          "ingress.#" => "1",
                          "name" => "default",
                        }
                      }
                    },
                    "aws_db_security_group.sgfoobar" => {
                      "type" => "aws_db_security_group",
                      "primary" => {
                        "id" => "sgfoobar",
                        "attributes" => {
                          "db_subnet_group_name" => "sgfoobar",
                          "id" => "sgfoobar",
                          "ingress.#" => "2",
                          "name" => "sgfoobar",
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
              "serial" => 89,
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
                    "aws_db_security_group.default" => {
                      "type" => "aws_db_security_group",
                      "primary" => {
                        "id" => "default",
                        "attributes" => {
                          "db_subnet_group_name" => "default",
                          "id" => "default",
                          "ingress.#" => "1",
                          "name" => "default",
                        }
                      }
                    },
                    "aws_db_security_group.sgfoobar" => {
                      "type" => "aws_db_security_group",
                      "primary" => {
                        "id" => "sgfoobar",
                        "attributes" => {
                          "db_subnet_group_name" => "sgfoobar",
                          "id" => "sgfoobar",
                          "ingress.#" => "2",
                          "name" => "sgfoobar",
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

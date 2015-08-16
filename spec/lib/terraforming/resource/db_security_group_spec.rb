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
          },
          {
            ip_ranges: [],
            owner_id: "123456789012",
            db_security_group_description: "empty",
            ec2_security_groups: [],
            db_security_group_name: "empty"
          },
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
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
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
          })
        end
      end
    end
  end
end

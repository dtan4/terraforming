require "spec_helper"

module Terraforming
  module Resource
    describe SecurityGroup do
      let(:client) do
        Aws::EC2::Client.new(stub_responses: true)
      end

      let(:security_groups) do
        [
          {
            owner_id: "012345678901",
            group_name: "hoge",
            group_id: "sg-1234abcd",
            description: "Group for hoge",
            ip_permissions: [
              {
                ip_protocol: "tcp",
                from_port: 22,
                to_port: 22,
                user_id_group_pairs: [],
                ip_ranges: [
                  { cidr_ip: "0.0.0.0/0" }
                ]
              }
            ],
            ip_permissions_egress: [
              {
                ip_protocol: "-1",
                user_id_group_pairs: [],
                ip_ranges: [
                  { cidr_ip: "0.0.0.0/0" }
                ]
              },
            ],
            vpc_id: nil,
            tags: []
          },
          {
            owner_id: "098765432109",
            group_name: "fuga",
            group_id: "sg-5678efgh",
            description: "Group for fuga",
            ip_permissions: [
              {
                ip_protocol: "tcp",
                from_port: 0,
                to_port: 65535,
                user_id_group_pairs: [
                  {
                    user_id: "001122334455",
                    group_name: "group1",
                    group_id: "sg-9012ijkl"
                  }
                ],
                ip_ranges: []
              },
              {
                ip_protocol: "tcp",
                from_port: 22,
                to_port: 22,
                user_id_group_pairs: [],
                ip_ranges: [
                  { cidr_ip: "0.0.0.0/0" }
                ]
              },
            ],
            ip_permissions_egress: [],
            vpc_id: "vpc-1234abcd",
            tags: [
              { key: "Name", value: "fuga" }
            ]
          }
        ]
      end

      before do
        client.stub_responses(:describe_security_groups, security_groups: security_groups)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client)).to eq <<-EOS
resource "aws_security_group" "sg-1234abcd-hoge" {
    name        = "hoge"
    description = "Group for hoge"
    vpc_id      = ""

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "sg-5678efgh-fuga" {
    name        = "fuga"
    description = "Group for fuga"
    vpc_id      = "vpc-1234abcd"

    ingress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        security_groups = ["sg-9012ijkl"]
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }


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
            "serial" => 1,
            "modules" => {
              "path" => [
                "root"
              ],
              "outputs" => {},
              "resources" => {
                "aws_security_group.sg-1234abcd-hoge" => {
                  "type" => "aws_security_group",
                  "primary" => {
                    "id" => "sg-1234abcd",
                    "attributes" => {
                      "description" => "Group for hoge",
                      "egress.#" => "1",
                      "id" => "sg-1234abcd",
                      "ingress.#" => "1",
                      "name" => "hoge",
                      "owner_id" => "012345678901",
                      "vpc_id" => "",
                    }
                  }
                },
                "aws_security_group.sg-5678efgh-fuga" => {
                  "type" => "aws_security_group",
                  "primary" => {
                    "id" => "sg-5678efgh",
                    "attributes" => {
                      "description" => "Group for fuga",
                      "egress.#" => "0",
                      "id" => "sg-5678efgh",
                      "ingress.#" => "2",
                      "name" => "fuga",
                      "owner_id" => "098765432109",
                      "vpc_id" => "vpc-1234abcd",
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
end

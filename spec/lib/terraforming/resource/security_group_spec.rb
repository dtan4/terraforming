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
                    group_id: "sg-5678efgh"
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
        security_groups = ["sg-5678efgh"]
        self            = true
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }


    tags {
        "Name" = "fuga"
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
            "modules" => [
              {
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
                        "id" => "sg-1234abcd",
                        "name" => "hoge",
                        "owner_id" => "012345678901",
                        "vpc_id" => "",
                        "egress.#" => "1",
                        "egress.482069346.from_port" => "0",
                        "egress.482069346.to_port" => "0",
                        "egress.482069346.protocol" => "-1",
                        "egress.482069346.cidr_blocks.#" => "1",
                        "egress.482069346.security_groups.#" => "0",
                        "egress.482069346.self" => "false",
                        "ingress.#" => "1",
                        "ingress.2541437006.from_port" => "22",
                        "ingress.2541437006.to_port" => "22",
                        "ingress.2541437006.protocol" => "tcp",
                        "ingress.2541437006.cidr_blocks.#" => "1",
                        "ingress.2541437006.security_groups.#" => "0",
                        "ingress.2541437006.self" => "false",
                      }
                    }
                  },
                  "aws_security_group.sg-5678efgh-fuga" => {
                    "type" => "aws_security_group",
                    "primary" => {
                      "id" => "sg-5678efgh",
                      "attributes" => {
                        "description" => "Group for fuga",
                        "id" => "sg-5678efgh",
                        "name" => "fuga",
                        "owner_id" => "098765432109",
                        "vpc_id" => "vpc-1234abcd",
                        "egress.#" => "0",
                        "ingress.#" => "2",
                        "ingress.1849628954.from_port" => "0",
                        "ingress.1849628954.to_port" => "65535",
                        "ingress.1849628954.protocol" => "tcp",
                        "ingress.1849628954.cidr_blocks.#" => "0",
                        "ingress.1849628954.security_groups.#" => "1",
                        "ingress.1849628954.self" => "true",
                        "ingress.2541437006.from_port" => "22",
                        "ingress.2541437006.to_port" => "22",
                        "ingress.2541437006.protocol" => "tcp",
                        "ingress.2541437006.cidr_blocks.#" => "1",
                        "ingress.2541437006.security_groups.#" => "0",
                        "ingress.2541437006.self" => "false",
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

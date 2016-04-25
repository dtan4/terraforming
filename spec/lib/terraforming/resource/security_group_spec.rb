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
              },
              {
                ip_protocol: "tcp",
                from_port: 22,
                to_port: 22,
                user_id_group_pairs: [
                  {
                    user_id: "098765432109",
                    group_id: "sg-9876uxyz",
                  }
                ],
                ip_ranges: []
              },
            ],
            ip_permissions_egress: [
              {
                ip_protocol: "-1",
                user_id_group_pairs: [
                  {
                    user_id: "098765432109",
                    group_id: "sg-9876uxyz",
                  }
                ],
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
              {
                ip_protocol: "tcp",
                from_port: 22,
                to_port: 22,
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
                from_port: 7777,
                to_port: 7777,
                user_id_group_pairs: [
                  {
                    user_id: "001122334455",
                    group_name: "group1",
                    group_id: "sg-5678efgh"
                  },
                  {
                    user_id: "001122334455",
                    group_name: "group1",
                    group_id: "sg-7777abcd"
                  }
                ],
                ip_ranges: []
              },
            ],
            ip_permissions_egress: [
              {
                ip_protocol: "tcp",
                from_port: 22,
                to_port: 22,
                user_id_group_pairs: [],
                ip_ranges: [
                  { cidr_ip: "0.0.0.0/0" }
                ]
              },
              {
                ip_protocol: "tcp",
                from_port: 22,
                to_port: 22,
                user_id_group_pairs: [
                  {
                    user_id: "001122334455",
                    group_name: "group1",
                    group_id: "sg-5678efgh"
                  }
                ],
                ip_ranges: []
              },
            ],
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
          expect(described_class.tf(client: client)).to eq <<-EOS
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

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        security_groups = ["sg-9876uxyz"]
        self            = false
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        security_groups = ["sg-9876uxyz"]
        self            = false
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
        self            = true
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        self            = true
    }

    ingress {
        from_port       = 7777
        to_port         = 7777
        protocol        = "tcp"
        security_groups = ["sg-7777abcd"]
        self            = true
    }


    egress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        self            = true
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
          expect(described_class.tfstate(client: client)).to eq({
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
                  "tags.#" => "0",
                  "egress.#" => "1",
                  "egress.2927967887.from_port" => "0",
                  "egress.2927967887.to_port" => "0",
                  "egress.2927967887.protocol" => "-1",
                  "egress.2927967887.cidr_blocks.#" => "1",
                  "egress.2927967887.security_groups.#" => "1",
                  "egress.2927967887.self" => "false",
                  "egress.2927967887.cidr_blocks.0" => "0.0.0.0/0",
                  "egress.2927967887.security_groups.855381352" => "sg-9876uxyz",
                  "ingress.#" => "2",
                  "ingress.2541437006.from_port" => "22",
                  "ingress.2541437006.to_port" => "22",
                  "ingress.2541437006.protocol" => "tcp",
                  "ingress.2541437006.cidr_blocks.#" => "1",
                  "ingress.2541437006.security_groups.#" => "0",
                  "ingress.2541437006.self" => "false",
                  "ingress.2541437006.cidr_blocks.0" => "0.0.0.0/0",
                  "ingress.2310343805.from_port" => "22",
                  "ingress.2310343805.to_port" => "22",
                  "ingress.2310343805.protocol" => "tcp",
                  "ingress.2310343805.cidr_blocks.#" => "0",
                  "ingress.2310343805.security_groups.#" => "1",
                  "ingress.2310343805.self" => "false",
                  "ingress.2310343805.security_groups.855381352" => "sg-9876uxyz",
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
                  "tags.#" => "1",
                  "tags.Name" => "fuga",
                  "egress.#" => "1",
                  "egress.1909903921.from_port" => "22",
                  "egress.1909903921.to_port" => "22",
                  "egress.1909903921.protocol" => "tcp",
                  "egress.1909903921.cidr_blocks.#" => "1",
                  "egress.1909903921.security_groups.#" => "0",
                  "egress.1909903921.self" => "true",
                  "egress.1909903921.cidr_blocks.0" => "0.0.0.0/0",
                  "ingress.#" => "2",
                  "ingress.1849628954.from_port" => "0",
                  "ingress.1849628954.to_port" => "65535",
                  "ingress.1849628954.protocol" => "tcp",
                  "ingress.1849628954.cidr_blocks.#" => "0",
                  "ingress.1849628954.security_groups.#" => "0",
                  "ingress.1849628954.self" => "true",
                  "ingress.1909903921.from_port" => "22",
                  "ingress.1909903921.to_port" => "22",
                  "ingress.1909903921.protocol" => "tcp",
                  "ingress.1909903921.cidr_blocks.#" => "1",
                  "ingress.1909903921.security_groups.#" => "0",
                  "ingress.1909903921.self" => "true",
                  "ingress.1909903921.cidr_blocks.0" => "0.0.0.0/0",
                  "ingress.#" => "3",
                  "ingress.1728187046.from_port" => "7777",
                  "ingress.1728187046.to_port" => "7777",
                  "ingress.1728187046.protocol" => "tcp",
                  "ingress.1728187046.cidr_blocks.#" => "0",
                  "ingress.1728187046.security_groups.#" => "1",
                  "ingress.1728187046.self" => "true",
                  "ingress.1728187046.security_groups.1756790741" => "sg-7777abcd"
                }
              }
            },
          })
        end
      end
    end
  end
end

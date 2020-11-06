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
                ],
                ipv_6_ranges: [
                  { cidr_ipv_6: "::/0" }
                ]
              },
              {
                ip_protocol: "tcp",
                from_port: 22,
                to_port: 22,
                user_id_group_pairs: [
                  {
                    user_id: "987654321012",
                    group_id: "sg-9876uxyz",
                    group_name: "piyo"
                  },
                  {
                    user_id: "012345678901",
                    group_id: "sg-1234abcd",
                    group_name: "hoge"
                  }
                ],
                ip_ranges: [],
                ipv_6_ranges: []
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
            vpc_id: "vpc-1234abcd",
            ip_permissions: [
              {
                ip_protocol: "tcp",
                from_port: 0,
                to_port: 65535,
                user_id_group_pairs: [
                  {
                    user_id: "098765432109",
                    group_name: nil,
                    group_id: "sg-5678efgh"
                  }
                ],
                ip_ranges: [],
                ipv_6_ranges: []
              },
              {
                ip_protocol: "tcp",
                from_port: 22,
                to_port: 22,
                user_id_group_pairs: [
                 {
                    user_id: "098765432109",
                    group_name: nil,
                    group_id: "sg-1234efgh"
                  }
                ],
                ip_ranges: [
                  { cidr_ip: "0.0.0.0/0" }
                ],
                ipv_6_ranges: [
                  { cidr_ipv_6: "::/0" }
                ]
              },
              {
                ip_protocol: "tcp",
                from_port: 7777,
                to_port: 7777,
                user_id_group_pairs: [
                 {
                    user_id: "098765432109",
                    group_name: nil,
                    group_id: "sg-5678efgh"
                 },
                 {
                    user_id: "098765432109",
                    group_name: nil,
                    group_id: "sg-7777abcd"
                  }
                ],
                ip_ranges: [],
                ipv_6_ranges: []
              },
            ],
            ip_permissions_egress: [
              {
                ip_protocol: "tcp",
                from_port: 22,
                to_port: 22,
                user_id_group_pairs: [
                  {
                    user_id: "098765432109",
                    group_name: nil,
                    group_id: "sg-5678efgh"
                  },
                  {
                    user_id: "098765432109",
                    group_name: nil,
                    group_id: "sg-1234efgh"
                  }
                ],
                ip_ranges: [
                  { cidr_ip: "0.0.0.0/0" }
                ],
                ipv_6_ranges: [
                  { cidr_ipv_6: "::/0" }
                ]
              },
            ],
            tags: [
              { key: "Name", value: "fuga" }
            ]
          },
          {
            owner_id: "098765432109",
            group_name: "piyo",
            group_id: "sg-9012ijkl",
            description: "Group for piyo",
            vpc_id: "vpc-1234abcd",
            ip_permissions: [
              {
                ip_protocol: "tcp",
                from_port: 22,
                to_port: 22,
                user_id_group_pairs: [
                 {
                    user_id: "098765432109",
                    group_name: nil,
                    group_id: "sg-9012ijkl"
                  }
                ],
                ip_ranges: [],
                ipv_6_ranges: []
              },
              {
                ip_protocol: "tcp",
                from_port: 22,
                to_port: 22,
                user_id_group_pairs: [],
                ip_ranges: [
                  { cidr_ip: "0.0.0.0/0" }
                ],
                ipv_6_ranges: [
                  { cidr_ipv_6: "::/0" }
                ]
              },
            ],
            ip_permissions_egress: [
              {
                ip_protocol: "-1",
                from_port: 1,
                to_port: 65535,
                user_id_group_pairs: [],
                ip_ranges: [
                  { cidr_ip: "0.0.0.0/0" }
                ],
                ipv_6_ranges: [
                  { cidr_ipv_6: "::/0" }
                ],
                prefix_list_ids: [
                  { prefix_list_id: "pl-xxxxxx" }
                ],
              },
            ],
            tags: [
              { key: "Name", value: "piyo" }
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
resource "aws_security_group" "hoge" {
    name        = "hoge"
    description = "Group for hoge"
    vpc_id      = ""

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        ipv6_cidr_blocks     = ["::/0"]
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        security_groups = ["987654321012/piyo"]
        self            = true
    }


}

resource "aws_security_group" "vpc-1234abcd-fuga" {
    name        = "fuga"
    description = "Group for fuga"
    vpc_id      = "vpc-1234abcd"

    ingress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        security_groups = []
        self            = true
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        ipv6_cidr_blocks     = ["::/0"]
        security_groups = ["sg-1234efgh"]
        self            = false
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
        ipv6_cidr_blocks     = ["::/0"]
        security_groups = ["sg-1234efgh"]
        self            = true
    }

    tags = {
        "Name" = "fuga"
    }
}

resource "aws_security_group" "vpc-1234abcd-piyo" {
    name        = "piyo"
    description = "Group for piyo"
    vpc_id      = "vpc-1234abcd"

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        ipv6_cidr_blocks     = ["::/0"]
        security_groups = []
        self            = true
    }


    egress {
        from_port       = 1
        to_port         = 65535
        protocol        = "-1"
        prefix_list_ids = ["pl-xxxxxx"]
        cidr_blocks     = ["0.0.0.0/0"]
        ipv6_cidr_blocks     = ["::/0"]
    }

    tags = {
        "Name" = "piyo"
    }
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_security_group.hoge" => {
              "type" => "aws_security_group",
              "primary" => {
                "id" => "sg-1234abcd",
                "attributes" => {
                  "description" => "Group for hoge",
                  "id" => "sg-1234abcd",
                  "name" => "hoge",
                  "owner_id" => "012345678901",
                  "tags.#" => "0",
                  "vpc_id" => "",
                  "egress.#" => "0",
                  "ingress.#" => "2",
                  "ingress.31326685.cidr_blocks.#" => "1",
                  "ingress.31326685.cidr_blocks.0" => "0.0.0.0/0",
                  "ingress.31326685.from_port" => "22",
                  "ingress.31326685.ipv6_cidr_blocks.#" => "1",
                  "ingress.31326685.ipv6_cidr_blocks.0" => "::/0",
                  "ingress.31326685.prefix_list_ids.#" => "0",
                  "ingress.31326685.protocol" => "tcp",
                  "ingress.31326685.security_groups.#" => "0",
                  "ingress.31326685.self" => "false",
                  "ingress.31326685.to_port" => "22",
                  "ingress.3232230010.cidr_blocks.#" => "0",
                  "ingress.3232230010.from_port" => "22",
                  "ingress.3232230010.ipv6_cidr_blocks.#" => "0",
                  "ingress.3232230010.prefix_list_ids.#" => "0",
                  "ingress.3232230010.protocol" => "tcp",
                  "ingress.3232230010.security_groups.#" => "1",
                  "ingress.3232230010.security_groups.1889292513" => "987654321012/piyo",
                  "ingress.3232230010.self" => "true",
                  "ingress.3232230010.to_port" => "22"
                }
              }
            },
            "aws_security_group.vpc-1234abcd-fuga" => {
              "type" => "aws_security_group",
              "primary" => {
                "id" => "sg-5678efgh",
                "attributes" => {
                  "description" => "Group for fuga",
                  "id" => "sg-5678efgh",
                  "name" => "fuga",
                  "owner_id" => "098765432109",
                  "tags.#" => "1",
                  "tags.Name" => "fuga",
                  "vpc_id" => "vpc-1234abcd",
                  "egress.#" => "1",
                  "egress.2007587753.cidr_blocks.#" => "1",
                  "egress.2007587753.cidr_blocks.0" => "0.0.0.0/0",
                  "egress.2007587753.from_port" => "22",
                  "egress.2007587753.ipv6_cidr_blocks.#" => "1",
                  "egress.2007587753.ipv6_cidr_blocks.0" => "::/0",
                  "egress.2007587753.prefix_list_ids.#" => "0",
                  "egress.2007587753.protocol" => "tcp",
                  "egress.2007587753.security_groups.#" => "1",
                  "egress.2007587753.security_groups.3311523735" => "sg-1234efgh",
                  "egress.2007587753.self" => "true",
                  "egress.2007587753.to_port" => "22",
                  "ingress.#" => "3",
                  "ingress.1728187046.cidr_blocks.#" => "0",
                  "ingress.1728187046.from_port" => "7777",
                  "ingress.1728187046.ipv6_cidr_blocks.#" => "0",
                  "ingress.1728187046.prefix_list_ids.#" => "0",
                  "ingress.1728187046.protocol" => "tcp",
                  "ingress.1728187046.security_groups.#" => "1",
                  "ingress.1728187046.security_groups.1756790741" => "sg-7777abcd",
                  "ingress.1728187046.self" => "true",
                  "ingress.1728187046.to_port" => "7777",
                  "ingress.1849628954.cidr_blocks.#" => "0",
                  "ingress.1849628954.from_port" => "0",
                  "ingress.1849628954.ipv6_cidr_blocks.#" => "0",
                  "ingress.1849628954.prefix_list_ids.#" => "0",
                  "ingress.1849628954.protocol" => "tcp",
                  "ingress.1849628954.security_groups.#" => "0",
                  "ingress.1849628954.self" => "true",
                  "ingress.1849628954.to_port" => "65535",
                  "ingress.2890765491.cidr_blocks.#" => "1",
                  "ingress.2890765491.cidr_blocks.0" => "0.0.0.0/0",
                  "ingress.2890765491.from_port" => "22",
                  "ingress.2890765491.ipv6_cidr_blocks.#" => "1",
                  "ingress.2890765491.ipv6_cidr_blocks.0" => "::/0",
                  "ingress.2890765491.prefix_list_ids.#" => "0",
                  "ingress.2890765491.protocol" => "tcp",
                  "ingress.2890765491.security_groups.#" => "1",
                  "ingress.2890765491.security_groups.3311523735" => "sg-1234efgh",
                  "ingress.2890765491.self" => "false",
                  "ingress.2890765491.to_port" => "22"
                },
              }
            },
            "aws_security_group.vpc-1234abcd-piyo" => {
              "type" => "aws_security_group",
              "primary"=>{
                "id" => "sg-9012ijkl",
                "attributes"=>{
                  "description" => "Group for piyo",
                  "id" => "sg-9012ijkl",
                  "name" => "piyo",
                  "owner_id" => "098765432109",
                  "tags.#" => "1",
                  "tags.Name" => "piyo",
                  "vpc_id" => "vpc-1234abcd",
                  "egress.#" => "1",
                  "egress.3936132414.cidr_blocks.#" => "1",
                  "egress.3936132414.cidr_blocks.0" => "0.0.0.0/0",
                  "egress.3936132414.from_port" => "1",
                  "egress.3936132414.ipv6_cidr_blocks.#" => "1",
                  "egress.3936132414.ipv6_cidr_blocks.0" => "::/0",
                  "egress.3936132414.prefix_list_ids.#" => "1",
                  "egress.3936132414.prefix_list_ids.0" => "pl-xxxxxx",
                  "egress.3936132414.protocol" => "-1",
                  "egress.3936132414.security_groups.#" => "0",
                  "egress.3936132414.self" => "false",
                  "egress.3936132414.to_port" => "65535",
                  "ingress.#" => "1",
                  "ingress.3239858.cidr_blocks.#" => "1",
                  "ingress.3239858.cidr_blocks.0" => "0.0.0.0/0",
                  "ingress.3239858.from_port" => "22",
                  "ingress.3239858.ipv6_cidr_blocks.#" => "1",
                  "ingress.3239858.ipv6_cidr_blocks.0" => "::/0",
                  "ingress.3239858.prefix_list_ids.#" => "0",
                  "ingress.3239858.protocol" => "tcp",
                  "ingress.3239858.security_groups.#" => "0",
                  "ingress.3239858.self" => "true",
                  "ingress.3239858.to_port" => "22"
                }
              }
            }
          })
        end
      end
    end
  end
end

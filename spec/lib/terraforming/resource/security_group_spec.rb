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
                ip_ranges: []
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
                ip_ranges: []
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
                ip_ranges: []
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
            ip_permissions_egress: [
              {
                ip_protocol: "-1",
                from_port: 1,
                to_port: 65535,
                user_id_group_pairs: [],
                ip_ranges: [
                  { cidr_ip: "0.0.0.0/0" }
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
        client.stub_responses(:describe_security_groups, -> (context) {
          group_ids = context.params[:group_ids]
          groups = if group_ids
                     security_groups.select { |sg|
                       group_ids.include? sg[:group_id]
                     }
                   else
                     security_groups
                   end
          { security_groups: groups }
        })
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
        security_groups = ["sg-1234efgh"]
        self            = true
    }

    tags {
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
        security_groups = []
        self            = true
    }


    egress {
        from_port       = 1
        to_port         = 65535
        protocol        = "-1"
        prefix_list_ids = ["pl-xxxxxx"]
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags {
        "Name" = "piyo"
    }
}

        EOS
        end

        context "with --group-ids" do
          it "should generate partial tf" do
            expect(described_class.tf({:client => client, "group-ids" => %w| sg-1234abcd |})).to eq <<-EOS
resource "aws_security_group" "hoge" {
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
        security_groups = ["987654321012/piyo"]
        self            = true
    }


}

          EOS
          end
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
                  "vpc_id" => "",
                  "tags.#" => "0",
                  "egress.#" => "0",
                  "ingress.#" => "2",
                  "ingress.2541437006.from_port" => "22",
                  "ingress.2541437006.to_port" => "22",
                  "ingress.2541437006.protocol" => "tcp",
                  "ingress.2541437006.cidr_blocks.#" => "1",
                  "ingress.2541437006.prefix_list_ids.#" => "0",
                  "ingress.2541437006.security_groups.#" => "0",
                  "ingress.2541437006.self" => "false",
                  "ingress.2541437006.cidr_blocks.0" => "0.0.0.0/0",
                  "ingress.3232230010.from_port" => "22",
                  "ingress.3232230010.to_port" => "22",
                  "ingress.3232230010.protocol" => "tcp",
                  "ingress.3232230010.cidr_blocks.#" => "0",
                  "ingress.3232230010.prefix_list_ids.#" => "0",
                  "ingress.3232230010.security_groups.#" => "1",
                  "ingress.3232230010.self" => "true",
                  "ingress.3232230010.security_groups.1889292513" => "987654321012/piyo",
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
                  "vpc_id" => "vpc-1234abcd",
                  "tags.#" => "1",
                  "tags.Name" => "fuga",
                  "egress.#" => "1",
                  "egress.2484852545.from_port" => "22",
                  "egress.2484852545.to_port" => "22",
                  "egress.2484852545.protocol" => "tcp",
                  "egress.2484852545.cidr_blocks.#" => "1",
                  "egress.2484852545.prefix_list_ids.#" => "0",
                  "egress.2484852545.security_groups.#" => "1",
                  "egress.2484852545.self" => "true",
                  "egress.2484852545.cidr_blocks.0" => "0.0.0.0/0",
                  "egress.2484852545.security_groups.3311523735" => "sg-1234efgh",
                  "ingress.#" => "3",
                  "ingress.1849628954.from_port" => "0",
                  "ingress.1849628954.to_port" => "65535",
                  "ingress.1849628954.protocol" => "tcp",
                  "ingress.1849628954.cidr_blocks.#" => "0",
                  "ingress.1849628954.prefix_list_ids.#" => "0",
                  "ingress.1849628954.security_groups.#" => "0",
                  "ingress.1849628954.self" => "true",
                  "ingress.1446312017.from_port" => "22",
                  "ingress.1446312017.to_port" => "22",
                  "ingress.1446312017.protocol" => "tcp",
                  "ingress.1446312017.cidr_blocks.#" => "1",
                  "ingress.1446312017.prefix_list_ids.#" => "0",
                  "ingress.1446312017.security_groups.#" => "1",
                  "ingress.1446312017.self" => "false",
                  "ingress.1446312017.security_groups.3311523735" => "sg-1234efgh",
                  "ingress.1446312017.cidr_blocks.0" => "0.0.0.0/0",
                  "ingress.1728187046.from_port" => "7777",
                  "ingress.1728187046.to_port" => "7777",
                  "ingress.1728187046.protocol" => "tcp",
                  "ingress.1728187046.cidr_blocks.#" => "0",
                  "ingress.1728187046.prefix_list_ids.#" => "0",
                  "ingress.1728187046.security_groups.#" => "1",
                  "ingress.1728187046.self" => "true",
                  "ingress.1728187046.security_groups.1756790741" => "sg-7777abcd"
                }
              }
            },
            "aws_security_group.vpc-1234abcd-piyo" => {
              "type" => "aws_security_group",
              "primary" => {
                "id" => "sg-9012ijkl",
                "attributes" => {
                  "description" => "Group for piyo",
                  "id" => "sg-9012ijkl",
                  "name" => "piyo",
                  "owner_id" => "098765432109",
                  "vpc_id" => "vpc-1234abcd",
                  "tags.#" => "1",
                  "tags.Name" => "piyo",
                  "egress.#" => "1",
                  "egress.1899000807.from_port" => "1",
                  "egress.1899000807.to_port" => "65535",
                  "egress.1899000807.protocol" => "-1",
                  "egress.1899000807.cidr_blocks.#" => "1",
                  "egress.1899000807.prefix_list_ids.#" => "1",
                  "egress.1899000807.security_groups.#" => "0",
                  "egress.1899000807.self" => "false",
                  "egress.1899000807.cidr_blocks.0" => "0.0.0.0/0",
                  "egress.1899000807.prefix_list_ids.0" => "pl-xxxxxx",
                  "ingress.#" => "1",
                  "ingress.1905676327.from_port" => "22",
                  "ingress.1905676327.to_port" => "22",
                  "ingress.1905676327.protocol" => "tcp",
                  "ingress.1905676327.cidr_blocks.#" => "1",
                  "ingress.1905676327.prefix_list_ids.#" => "0",
                  "ingress.1905676327.security_groups.#" => "0",
                  "ingress.1905676327.self" => "true",
                  "ingress.1905676327.cidr_blocks.0" => "0.0.0.0/0",
                }
              }
            },
          })
        end

        context "with --group-ids" do
          it "should generate partial tfstate" do
            expect(described_class.tfstate({:client => client, "group-ids" => %w| sg-1234abcd |})).to eq({
              "aws_security_group.hoge" => {
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
                      "egress.#" => "0",
                      "ingress.#" => "2",
                      "ingress.2541437006.from_port" => "22",
                      "ingress.2541437006.to_port" => "22",
                      "ingress.2541437006.protocol" => "tcp",
                      "ingress.2541437006.cidr_blocks.#" => "1",
                      "ingress.2541437006.prefix_list_ids.#" => "0",
                      "ingress.2541437006.security_groups.#" => "0",
                      "ingress.2541437006.self" => "false",
                      "ingress.2541437006.cidr_blocks.0" => "0.0.0.0/0",
                      "ingress.3232230010.from_port" => "22",
                      "ingress.3232230010.to_port" => "22",
                      "ingress.3232230010.protocol" => "tcp",
                      "ingress.3232230010.cidr_blocks.#" => "0",
                      "ingress.3232230010.prefix_list_ids.#" => "0",
                      "ingress.3232230010.security_groups.#" => "1",
                      "ingress.3232230010.self" => "true",
                      "ingress.3232230010.security_groups.1889292513" => "987654321012/piyo",
                  }
                }
              },
            })
          end
        end
      end
    end
  end
end

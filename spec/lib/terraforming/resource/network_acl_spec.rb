require "spec_helper"

module Terraforming
  module Resource
    describe NetworkACL do
      let(:client) do
        Aws::EC2::Client.new(stub_responses: true)
      end

      let(:network_acls) do
        [
          {
            network_acl_id: "acl-1234abcd",
            vpc_id: "vpc-1234abcd",
            is_default: true,
            entries: [
              {
                rule_number: 100,
                protocol: "-1",
                rule_action: "allow",
                egress: false,
                cidr_block: "0.0.0.0/0",
                port_range: nil,
              },
              {
                rule_number: 32767,
                protocol: "-1",
                rule_action: "deny",
                egress: true,
                cidr_block: "0.0.0.0/0",
                port_range: {
                  from: 80,
                  to: 80,
                },
              },
            ],
            associations: [
              {
                network_acl_association_id: "aclassoc-1234abcd",
                network_acl_id: "acl-1234abcd",
                subnet_id: "subnet-1234abcd"
              },
              {
                network_acl_association_id: "aclassoc-5678efgh",
                network_acl_id: "acl-1234abcd",
                subnet_id: "subnet-5678efgh"
              },
            ],
            tags: [
              { key: "Name", value: "hoge" },
            ]
          },
          {
            network_acl_id: "acl-5678efgh",
            vpc_id: "vpc-5678efgh",
            is_default: true,
            entries: [
              {
                rule_number: 100,
                protocol: "-1",
                rule_action: "allow",
                egress: false,
                cidr_block: "0.0.0.0/0",
                port_range: nil,
              },
              {
                rule_number: 12345,
                protocol: "1",
                rule_action: "allow",
                egress: false,
                cidr_block: "0.0.0.0/0",
                port_range: nil,
                icmp_type_code: {
                  code: -1,
                  type: 10,
                },
              },
              {
                rule_number: 15000,
                protocol: "1",
                rule_action: "allow",
                egress: true,
                cidr_block: "0.0.0.0/0",
                port_range: nil,
                icmp_type_code: {
                  code: -1,
                  type: 4
                },
              },
              {
                rule_number: 32767,
                protocol: "-1",
                rule_action: "deny",
                egress: true,
                cidr_block: "0.0.0.0/0",
                port_range: {
                  from: 80,
                  to: 80
                }
              },
            ],
            associations: [
              {
                network_acl_association_id: "aclassoc-9012ijkl",
                network_acl_id: "acl-5678efgh",
                subnet_id: "subnet-9012ijkl"
              },
              {
                network_acl_association_id: "aclassoc-3456mnop",
                network_acl_id: "acl-5678efgh",
                subnet_id: "subnet-3456mnop"
              },
            ],
            tags: [
              { key: "Name", value: "fuga" },
            ]
          },
        ]
      end

      before do
        client.stub_responses(:describe_network_acls, network_acls: network_acls)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_network_acl" "hoge" {
    vpc_id     = "vpc-1234abcd"
    subnet_ids = ["subnet-1234abcd", "subnet-5678efgh"]

    ingress {
        from_port  = 0
        to_port    = 0
        rule_no    = 100
        action     = "allow"
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
    }

    tags {
        "Name" = "hoge"
    }
}

resource "aws_network_acl" "fuga" {
    vpc_id     = "vpc-5678efgh"
    subnet_ids = ["subnet-9012ijkl", "subnet-3456mnop"]

    ingress {
        from_port  = 0
        to_port    = 0
        rule_no    = 100
        action     = "allow"
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
    }

    ingress {
        from_port  = 0
        to_port    = 0
        rule_no    = 12345
        action     = "allow"
        protocol   = "1"
        cidr_block = "0.0.0.0/0"
        icmp_code  = "-1"
        icmp_type  = "10"
    }

    egress {
        from_port  = 0
        to_port    = 0
        rule_no    = 15000
        action     = "allow"
        protocol   = "1"
        cidr_block = "0.0.0.0/0"
        icmp_code  = "-1"
        icmp_type  = "4"
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
            "aws_network_acl.hoge" => {
              "type" => "aws_network_acl",
              "primary" => {
                "id" => "acl-1234abcd",
                "attributes" => {
                  "egress.#" => "0",
                  "id" => "acl-1234abcd",
                  "ingress.#" => "1",
                  "subnet_ids.#" => "2",
                  "tags.#" => "1",
                  "vpc_id" => "vpc-1234abcd",
                }
              }
            },
            "aws_network_acl.fuga" => {
              "type" => "aws_network_acl",
              "primary" => {
                "id" => "acl-5678efgh",
                "attributes" => {
                  "egress.#" => "1",
                  "id" => "acl-5678efgh",
                  "ingress.#" => "2",
                  "subnet_ids.#" => "2",
                  "tags.#" => "1",
                  "vpc_id" => "vpc-5678efgh",
                }
              }
            },
          })
        end
      end
    end
  end
end

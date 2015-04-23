require "spec_helper"

module Terraforming::Resource
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
            {
              key: "Name",
              value: "hoge"
            },
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
            {
              key: "Name",
              value: "fuga"
            },
          ]
        },
      ]
    end

    before do
      client.stub_responses(:describe_network_acls, network_acls: network_acls)
    end

    describe ".tf" do
      it "should generate tf" do
        expect(described_class.tf(client)).to eq <<-EOS
resource "aws_network_acl" "hoge" {
    vpc_id = "vpc-1234abcd"

    ingress {
        from_port  = 0
        to_port    = 65535
        rule_no    = 100
        action     = "allow"
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
    }

    egress {
        from_port  = 80
        to_port    = 80
        rule_no    = 32767
        action     = "deny"
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
    }
}

resource "aws_network_acl" "fuga" {
    vpc_id = "vpc-5678efgh"

    ingress {
        from_port  = 0
        to_port    = 65535
        rule_no    = 100
        action     = "allow"
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
    }

    egress {
        from_port  = 80
        to_port    = 80
        rule_no    = 32767
        action     = "deny"
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
    }
}

        EOS
      end
    end

    describe ".tfstate" do
      xit "should generate tfstate" do
        expect(described_class.tfstate(client)).to eq JSON.pretty_generate({
          "version" => 1,
          "serial" => 1,
          "modules" => {
            "path" => [
              "root"
            ],
            "outputs" => {},
            "resources" => {
              "aws_security_group.hoge" => {
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
              "aws_security_group.fuga" => {
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

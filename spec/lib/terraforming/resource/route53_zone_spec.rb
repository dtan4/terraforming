require "spec_helper"

module Terraforming
  module Resource
    describe Route53Zone do
      let(:client) do
        Aws::Route53::Client.new(stub_responses: true)
      end

      let(:hosted_zones) do
        [
          {
            id: "/hostedzone/ABCDEFGHIJKLMN",
            name: "hoge.net.",
            caller_reference: "ABCDEFGH-1234-IJKL-5678-MNOPQRSTUVWX",
            config: { private_zone: false },
            resource_record_set_count: 4
          },
          {
            id: "/hostedzone/OPQRSTUVWXYZAB",
            name: "fuga.net.",
            caller_reference: "ABCDEFGH-5678-IJKL-9012-MNOPQRSTUVWX",
            config: { private_zone: false },
            resource_record_set_count: 4
          },
        ]
      end

      let(:hoge_resource_tag_set) do
        {
          resource_type: "hostedzone",
          resource_id: "ABCDEFGHIJKLMN",
          tags: [
            { key: "Environment", value: "dev" }
          ]
        }
      end

      let(:fuga_resource_tag_set) do
        {
          resource_type: "hostedzone",
          resource_id: "OPQRSTUVWXYZAB",
          tags: [
            { key: "Environment", value: "dev" }
          ]
        }
      end

      let(:hoge_delegation_set) do
        {
          name_servers: %w(ns-1234.awsdns-12.co.uk ns-567.awsdns-34.net ns-8.awsdns-56.com ns-9012.awsdns-78.org)
        }
      end

      let(:fuga_delegation_set) do
        {
          name_servers: %w(ns-5678.awsdns-12.co.uk ns-901.awsdns-34.net ns-2.awsdns-56.com ns-3456.awsdns-78.org)
        }
      end

      before do
        client.stub_responses(:list_hosted_zones, hosted_zones: hosted_zones)
        client.stub_responses(:list_tags_for_resource, [
          { resource_tag_set: hoge_resource_tag_set },
          { resource_tag_set: fuga_resource_tag_set },
        ])
        client.stub_responses(:get_hosted_zone, [
          { delegation_set: hoge_delegation_set },
          { delegation_set: fuga_delegation_set },
        ])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client)).to eq <<-EOS
resource "aws_route53_zone" "hoge-net" {
    name = "hoge.net"

    tags {
        Environment = "dev"
    }
}

resource "aws_route53_zone" "fuga-net" {
    name = "fuga.net"

    tags {
        Environment = "dev"
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
                "aws_instance.hoge"=> {
                  "type"=> "aws_instance",
                  "primary"=> {
                    "id"=> "i-1234abcd",
                    "attributes"=> {
                      "ami"=> "ami-1234abcd",
                      "associate_public_ip_address"=> "true",
                      "availability_zone"=> "ap-northeast-1b",
                      "ebs_block_device.#"=> "1",
                      "ebs_optimized"=> "false",
                      "ephemeral_block_device.#"=> "0",
                      "id"=> "i-1234abcd",
                      "instance_type"=> "t2.micro",
                      "private_dns"=> "ip-10-0-0-100.ap-northeast-1.compute.internal",
                      "private_ip"=> "10.0.0.100",
                      "public_dns"=> "ec2-54-12-0-0.ap-northeast-1.compute.amazonaws.com",
                      "public_ip"=> "54.12.0.0",
                      "root_block_device.#"=> "1",
                      "security_groups.#"=> "1",
                      "source_dest_check"=> "true",
                      "subnet_id"=> "subnet-1234abcd",
                      "tenancy"=> "default"
                    },
                    "meta"=> {
                      "schema_version"=> "1"
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

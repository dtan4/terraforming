require "spec_helper"

module Terraforming
  module Resource
    describe Route53Zone do
      let(:client) do
        Aws::Route53::Client.new(stub_responses: true)
      end

      let(:hoge_hosted_zone) do
          {
            id: "/hostedzone/ABCDEFGHIJKLMN",
            name: "hoge.net.",
            caller_reference: "ABCDEFGH-1234-IJKL-5678-MNOPQRSTUVWX",
            config: { private_zone: false },
            resource_record_set_count: 4,
          }
      end

      let(:fuga_hosted_zone) do
        {
          id: "/hostedzone/OPQRSTUVWXYZAB",
          name: "fuga.net.",
          caller_reference: "ABCDEFGH-5678-IJKL-9012-MNOPQRSTUVWX",
          config: { private_zone: false },
          resource_record_set_count: 4
        }
      end

      let(:hosted_zones) do
        [hoge_hosted_zone, fuga_hosted_zone]
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
        client.stub_responses(:list_hosted_zones,
          hosted_zones: hosted_zones, marker: "", is_truncated: false, max_items: 1)
        client.stub_responses(:list_tags_for_resource, [
          { resource_tag_set: hoge_resource_tag_set },
          { resource_tag_set: fuga_resource_tag_set },
        ])
        client.stub_responses(:get_hosted_zone, [
          { hosted_zone: hoge_hosted_zone, delegation_set: hoge_delegation_set },
          { hosted_zone: fuga_hosted_zone, delegation_set: fuga_delegation_set },
        ])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_route53_zone" "hoge-net" {
    name = "hoge.net"

    tags {
        "Environment" = "dev"
    }
}

resource "aws_route53_zone" "fuga-net" {
    name = "fuga.net"

    tags {
        "Environment" = "dev"
    }
}

        EOS
        end
      end

      describe ".tfstate" do
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
                  "aws_route53_zone.hoge-net"=> {
                    "type"=> "aws_route53_zone",
                    "primary"=> {
                      "id"=> "ABCDEFGHIJKLMN",
                      "attributes"=> {
                        "id"=> "ABCDEFGHIJKLMN",
                        "name"=> "hoge.net",
                        "name_servers.#" => "4",
                        "tags.#" => "1",
                        "zone_id" => "ABCDEFGHIJKLMN",
                      },
                    }
                  },
                  "aws_route53_zone.fuga-net"=> {
                    "type"=> "aws_route53_zone",
                    "primary"=> {
                      "id"=>  "OPQRSTUVWXYZAB",
                      "attributes"=> {
                        "id"=> "OPQRSTUVWXYZAB",
                        "name"=> "fuga.net",
                        "name_servers.#" => "4",
                        "tags.#" => "1",
                        "zone_id" => "OPQRSTUVWXYZAB",
                      },
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

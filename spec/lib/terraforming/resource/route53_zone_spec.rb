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
          config: {
            comment: "",
            private_zone: false
          },
          resource_record_set_count: 4,
        }
      end

      let(:fuga_hosted_zone) do
        {
          id: "/hostedzone/OPQRSTUVWXYZAB",
          name: "fuga.net.",
          caller_reference: "ABCDEFGH-5678-IJKL-9012-MNOPQRSTUVWX",
          config: {
            comment: "fuga.net zone comment",
            private_zone: true
          },
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

      let(:fuga_vp_cs) do
        [
          { vpc_region: "ap-northeast-1", vpc_id: "vpc-1234abcd" }
        ]
      end

      before do
        client.stub_responses(:list_hosted_zones,
                              hosted_zones: hosted_zones, marker: "", is_truncated: false, max_items: 1)
        client.stub_responses(:list_tags_for_resource, [
          { resource_tag_set: hoge_resource_tag_set },
          { resource_tag_set: fuga_resource_tag_set },
        ])
        client.stub_responses(:get_hosted_zone, [
          { hosted_zone: hoge_hosted_zone, delegation_set: hoge_delegation_set, vp_cs: [] },
          { hosted_zone: fuga_hosted_zone, delegation_set: nil, vp_cs: fuga_vp_cs },
        ])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_route53_zone" "hoge-net-public" {
    name       = "hoge.net"
    comment    = ""

    tags {
        "Environment" = "dev"
    }
}

resource "aws_route53_zone" "fuga-net-private" {
    name       = "fuga.net"
    comment    = "fuga.net zone comment"
    vpc_id     = "vpc-1234abcd"
    vpc_region = "ap-northeast-1"

    tags {
        "Environment" = "dev"
    }
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_route53_zone.hoge-net-public" => {
              "type" => "aws_route53_zone",
              "primary" => {
                "id" => "ABCDEFGHIJKLMN",
                "attributes" => {
                  "comment" => "",
                  "id" => "ABCDEFGHIJKLMN",
                  "name" => "hoge.net",
                  "name_servers.#" => "4",
                  "tags.#" => "1",
                  "vpc_id" => "",
                  "vpc_region" => "",
                  "zone_id" => "ABCDEFGHIJKLMN",
                },
              }
            },
            "aws_route53_zone.fuga-net-private" => {
              "type" => "aws_route53_zone",
              "primary" => {
                "id" => "OPQRSTUVWXYZAB",
                "attributes" => {
                  "comment" => "fuga.net zone comment",
                  "id" => "OPQRSTUVWXYZAB",
                  "name" => "fuga.net",
                  "name_servers.#" => "0",
                  "tags.#" => "1",
                  "vpc_id" => "vpc-1234abcd",
                  "vpc_region" => "ap-northeast-1",
                  "zone_id" => "OPQRSTUVWXYZAB",
                },
              }
            },
          })
        end
      end
    end
  end
end

require "spec_helper"

module Terraforming
  module Resource
    describe Route53Record do
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
          {
            id: "/hostedzone/CDEFGHIJKLMNOP",
            name: "example.net.",
            caller_reference: "ABCDEFGH-9012-IJKL-9012-MNOPQRSTUVWX",
            config: { private_zone: false },
            resource_record_set_count: 4
          },
        ]
      end

      let(:hoge_resource_record_sets) do
        [
          {
            name: "hoge.net.",
            type: "A",
            ttl: 3600,
            weight: nil,
            set_identifier: "dev",
            resource_records: [
              { value: "123.456.78.90" },
              { value: "hoge.awsdns-60.org" },
            ],
          }
        ]
      end

      let(:fuga_resource_record_sets) do
        [
          {
            name: "www.fuga.net.",
            type: "A",
            ttl: nil,
            weight: 10,
            set_identifier: nil,
            alias_target: {
              hosted_zone_id: "ABCDEFGHIJ1234",
              dns_name: "fuga.net.",
              evaluate_target_health: false,
            },
          }
        ]
      end

      let(:piyo_resource_record_sets) do
        [
          {
            name: '\052.example.net.',
            type: "CNAME",
            ttl: 3600,
            weight: nil,
            set_identifier: nil,
            resource_records: [
              { value: "example.com" }
            ]
          },
          {
            name: "geo.example.net.",
            type: "A",
            ttl: 3600,
            weight: nil,
            set_identifier: nil,
            geo_location: {
              continent_code: "AS",
              country_code: "JP",
            },
          },
          {
            name: "geo.example.net.",
            type: "A",
            ttl: 60,
            weight: nil,
            set_identifier: nil,
          },
          {
            name: "failover.example.net.",
            type: "A",
            ttl: 3600,
            weight: nil,
            set_identifier: "failover_group",
            health_check_id: "1234abcd-56ef-78gh-90ij-123456klmnop",
            resource_records: [
              { value: "192.0.2.101" }
            ],
            failover: "PRIMARY"
          },
          {
            name: "failover.example.net.",
            type: "A",
            ttl: 3600,
            weight: nil,
            set_identifier: "failover_group",
            resource_records: [
              { value: "192.0.2.102" }
            ],
            failover: "SECONDARY"
          },
        ]
      end

      before do
        client.stub_responses(:list_hosted_zones,
                              hosted_zones: hosted_zones, marker: "", is_truncated: false, max_items: 1)
        client.stub_responses(:list_resource_record_sets, [
          { resource_record_sets: hoge_resource_record_sets, is_truncated: false, max_items: 1 },
          { resource_record_sets: fuga_resource_record_sets, is_truncated: false, max_items: 1 },
          { resource_record_sets: piyo_resource_record_sets, is_truncated: false, max_items: 1 },
        ])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_route53_record" "hoge-net-A" {
    zone_id = "ABCDEFGHIJKLMN"
    name    = "hoge.net"
    type    = "A"
    records = ["123.456.78.90", "hoge.awsdns-60.org"]
    ttl     = "3600"
    set_identifier = "dev"

}

resource "aws_route53_record" "www-fuga-net-A" {
    zone_id = "OPQRSTUVWXYZAB"
    name    = "www.fuga.net"
    type    = "A"
    weighted_routing_policy {
        weight = 10
    }

    alias {
        name    = "fuga.net"
        zone_id = "ABCDEFGHIJ1234"
        evaluate_target_health = false
    }
}

resource "aws_route53_record" "wildcard-example-net-CNAME" {
    zone_id = "CDEFGHIJKLMNOP"
    name    = "*.example.net"
    type    = "CNAME"
    records = ["example.com"]
    ttl     = "3600"

}

resource "aws_route53_record" "geo-example-net-A-0" {
    zone_id = "CDEFGHIJKLMNOP"
    name    = "geo.example.net"
    type    = "A"
    ttl     = "3600"

    geolocation_routing_policy {
        continent = "AS"
        country = "JP"
    }

}

resource "aws_route53_record" "geo-example-net-A-1" {
    zone_id = "CDEFGHIJKLMNOP"
    name    = "geo.example.net"
    type    = "A"
    ttl     = "60"

}

resource "aws_route53_record" "failover-example-net-A-0" {
    zone_id = "CDEFGHIJKLMNOP"
    name    = "failover.example.net"
    type    = "A"
    records = ["192.0.2.101"]
    ttl     = "3600"
    set_identifier = "failover_group"
    health_check_id = "1234abcd-56ef-78gh-90ij-123456klmnop"

    failover_routing_policy {
        type = "PRIMARY"
    }

}

resource "aws_route53_record" "failover-example-net-A-1" {
    zone_id = "CDEFGHIJKLMNOP"
    name    = "failover.example.net"
    type    = "A"
    records = ["192.0.2.102"]
    ttl     = "3600"
    set_identifier = "failover_group"

    failover_routing_policy {
        type = "SECONDARY"
    }

}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_route53_record.hoge-net-A" => {
              "type" => "aws_route53_record",
              "primary" => {
                "id" => "ABCDEFGHIJKLMN_hoge.net_A",
                "attributes" => {
                  "id" => "ABCDEFGHIJKLMN_hoge.net_A",
                  "name" => "hoge.net",
                  "type" => "A",
                  "zone_id" => "ABCDEFGHIJKLMN",
                  "records.#" => "2",
                  "ttl" => "3600",
                  "set_identifier" => "dev",
                  "weight" => "-1",
                },
              }
            },
            "aws_route53_record.www-fuga-net-A" => {
              "type" => "aws_route53_record",
              "primary" => {
                "id" => "OPQRSTUVWXYZAB_www.fuga.net_A",
                "attributes" => {
                  "id" => "OPQRSTUVWXYZAB_www.fuga.net_A",
                  "name" => "www.fuga.net",
                  "type" => "A",
                  "zone_id" => "OPQRSTUVWXYZAB",
                  "alias.#" => "1",
                  "weight" => "10",
                },
              }
            },
            "aws_route53_record.wildcard-example-net-CNAME" => {
              "type" => "aws_route53_record",
              "primary" => {
                "id" => "CDEFGHIJKLMNOP_*.example.net_CNAME",
                "attributes" => {
                  "id" => "CDEFGHIJKLMNOP_*.example.net_CNAME",
                  "name" => "*.example.net",
                  "type" => "CNAME",
                  "zone_id" => "CDEFGHIJKLMNOP",
                  "records.#" => "1",
                  "ttl" => "3600",
                  "weight" => "-1",
                },
              }
            },
            "aws_route53_record.geo-example-net-A-0" => {
              "type" => "aws_route53_record",
              "primary" => {
                "id" => "CDEFGHIJKLMNOP_geo.example.net_A",
                "attributes" => {
                  "id" => "CDEFGHIJKLMNOP_geo.example.net_A",
                  "name" => "geo.example.net",
                  "type" => "A",
                  "zone_id" => "CDEFGHIJKLMNOP",
                  "weight" => "-1",
                  "ttl" => "3600",
                  "continent" => "AS",
                  "country" => "JP",
                },
              }
            },
            "aws_route53_record.geo-example-net-A-1" => {
              "type" => "aws_route53_record",
              "primary" => {
                "id" => "CDEFGHIJKLMNOP_geo.example.net_A",
                "attributes" => {
                  "id" => "CDEFGHIJKLMNOP_geo.example.net_A",
                  "name" => "geo.example.net",
                  "type" => "A",
                  "zone_id" => "CDEFGHIJKLMNOP",
                  "weight" => "-1",
                  "ttl" => "60",
                },
              }
            },
            "aws_route53_record.failover-example-net-A-0" => {
              "type" => "aws_route53_record",
              "primary" => {
                "id" => "CDEFGHIJKLMNOP_failover.example.net_A",
                "attributes" => {
                  "failover_routing_policy.#" => "1",
                  "failover_routing_policy.0.type" => "PRIMARY",
                  "health_check_id" => "1234abcd-56ef-78gh-90ij-123456klmnop",
                  "id" => "CDEFGHIJKLMNOP_failover.example.net_A",
                  "name" => "failover.example.net",
                  "type" => "A",
                  "zone_id" => "CDEFGHIJKLMNOP",
                  "records.#" => "1",
                  "weight" => "-1",
                  "ttl" => "3600",
                  "set_identifier" => "failover_group",
                },
              }
            },
            "aws_route53_record.failover-example-net-A-1" => {
              "type" => "aws_route53_record",
              "primary" => {
                "id" => "CDEFGHIJKLMNOP_failover.example.net_A",
                "attributes" => {
                  "failover_routing_policy.#" => "1",
                  "failover_routing_policy.0.type" => "SECONDARY",
                  "id" => "CDEFGHIJKLMNOP_failover.example.net_A",
                  "name" => "failover.example.net",
                  "type" => "A",
                  "zone_id" => "CDEFGHIJKLMNOP",
                  "records.#" => "1",
                  "weight" => "-1",
                  "ttl" => "3600",
                  "set_identifier" => "failover_group",
                },
              }
            },
          })
        end
      end
    end
  end
end

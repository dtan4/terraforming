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
            ttl: 600,
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

      before do
        client.stub_responses(:list_hosted_zones, hosted_zones: hosted_zones)
        client.stub_responses(:list_resource_record_sets, [
          { resource_record_sets: hoge_resource_record_sets },
          { resource_record_sets: fuga_resource_record_sets },
        ])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client)).to eq <<-EOS
resource "aws_route53_record" "hoge-net" {
    zone_id = "ABCDEFGHIJKLMN"
    name    = "hoge.net"
    type    = "A"
    ttl     = "3600"
    records = ["123.456.78.90", "hoge.awsdns-60.org"]
    set_identifier = "dev"

}

resource "aws_route53_record" "www-fuga-net" {
    zone_id = "OPQRSTUVWXYZAB"
    name    = "www.fuga.net"
    type    = "A"
    ttl     = "600"
    weight  = 10

    alias {
        name    = "fuga.net"
        zone_id = "ABCDEFGHIJ1234"
        evaluate_target_length = false
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
            "modules" => {
              "path" => [
                "root"
              ],
              "outputs" => {},
              "resources" => {
                "aws_route53_record.hoge-net" => {
                  "type" => "aws_route53_record",
                  "primary" => {
                    "id" => "ABCDEFGHIJKLMN_hoge.net_A",
                    "attributes"=> {
                      "id" => "ABCDEFGHIJKLMN_hoge.net_A",
                      "name" => "hoge.net",
                      "ttl" => "3600",
                      "type" => "A",
                      "zone_id" => "ABCDEFGHIJKLMN",
                      "records.#" => "2",
                      "set_identifier" => "dev",
                    },
                  }
                },
                "aws_route53_record.www-fuga-net" => {
                  "type" => "aws_route53_record",
                  "primary" => {
                    "id" => "OPQRSTUVWXYZAB_www.fuga.net_A",
                    "attributes" => {
                      "id" => "OPQRSTUVWXYZAB_www.fuga.net_A",
                      "name" => "www.fuga.net",
                      "ttl" => "600",
                      "type" => "A",
                      "zone_id" => "OPQRSTUVWXYZAB",
                      "weight" => "10",
                    },
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

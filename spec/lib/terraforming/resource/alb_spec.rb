require "spec_helper"

module Terraforming
  module Resource
    describe ALB do
      let(:client) do
        Aws::ElasticLoadBalancingV2::Client.new(stub_responses: true)
      end

      let(:load_balancers) do
        [
          {
            load_balancer_arn: "arn:aws:elasticloadbalancing:ap-northeast-1:012345678901:loadbalancer/app/hoge/1234abcd1234abcd",
            dns_name: "hoge-123456789.ap-northeast-1.elb.amazonaws.com",
            canonical_hosted_zone_id: "12345678ABCDEF",
            created_time: Time.parse("2016-08-19 00:39:01 UTC"),
            load_balancer_name: "hoge",
            scheme: "internet-facing",
            vpc_id: "vpc-1234abcd",
            state: { code: "active" },
            type: "application",
            availability_zones: [
              { zone_name: "ap-northeast-1c", subnet_id: "subnet-1234abcd" },
              { zone_name: "ap-northeast-1b", subnet_id: "subnet-5678efgh" }
            ],
            security_groups: ["sg-1234abcd", "sg-5678efgh"]
          },
          {
            load_balancer_arn: "arn:aws:elasticloadbalancing:ap-northeast-1:012345678901:loadbalancer/app/fuga/5678efgh5678efgh",
            dns_name: "fuga-567891234.ap-northeast-1.elb.amazonaws.com",
            canonical_hosted_zone_id: "12345678ABCDEF",
            created_time: Time.parse("2016-08-31 06:23:57 UTC"),
            load_balancer_name: "fuga",
            scheme: "internal",
            vpc_id: "vpc-5678efgh",
            state: { code: "active" },
            type: "application",
            availability_zones: [
              { zone_name: "ap-northeast-1c", subnet_id: "subnet-1234abcd" },
              { zone_name: "ap-northeast-1b", subnet_id: "subnet-9012ijkl" }
            ],
            security_groups: ["sg-1234abcd"]
          },
        ]
      end

      let(:hoge_attributes) do
        [
          { key: "access_logs.s3.enabled", value: "true" },
          { key: "idle_timeout.timeout_seconds", value: "600" },
          { key: "access_logs.s3.prefix", value: "hoge" },
          { key: "deletion_protection.enabled", value: "false" },
          { key: "access_logs.s3.bucket", value: "my-elb-logs" },
        ]
      end

      let(:fuga_attributes) do
        [
          { key: "access_logs.s3.enabled", value: "false" },
          { key: "idle_timeout.timeout_seconds", value: "60" },
          { key: "access_logs.s3.prefix", value: "fuga" },
          { key: "deletion_protection.enabled", value: "true" },
          { key: "access_logs.s3.bucket", value: "my-elb-logs" },
        ]
      end

      let(:hoge_tag_descriptions) do
        [
          {
            resource_arn: "arn:aws:elasticloadbalancing:ap-northeast-1:012345678901:loadbalancer/app/hoge/1234abcd1234abcd",
            tags: [
              { key: "Environment", value: "Production" }
            ]
          }
        ]
      end

      let(:fuga_tag_descriptions) do
        [
          {
            resource_arn: "arn:aws:elasticloadbalancing:ap-northeast-1:012345678901:loadbalancer/app/fuga/5678efgh5678efgh",
            tags: []
          }
        ]
      end

      before do
        client.stub_responses(:describe_load_balancers, load_balancers: load_balancers)
        client.stub_responses(:describe_load_balancer_attributes, [
          { attributes: hoge_attributes },
          { attributes: fuga_attributes },
        ])
        client.stub_responses(:describe_tags, [
          { tag_descriptions: hoge_tag_descriptions },
          { tag_descriptions: fuga_tag_descriptions },
        ])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_alb" "hoge" {
    idle_timeout    = 600
    internal        = false
    name            = "hoge"
    security_groups = ["sg-1234abcd", "sg-5678efgh"]
    subnets         = ["subnet-1234abcd", "subnet-5678efgh"]

    enable_deletion_protection = false

    access_logs {
        bucket  = "my-elb-logs"
        enabled = true
        prefix  = "hoge"
    }

    tags {
        "Environment" = "Production"
    }
}

resource "aws_alb" "fuga" {
    idle_timeout    = 60
    internal        = true
    name            = "fuga"
    security_groups = ["sg-1234abcd"]
    subnets         = ["subnet-1234abcd", "subnet-9012ijkl"]

    enable_deletion_protection = true

    tags {
    }
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_alb.hoge" => {
              "type" => "aws_alb",
              "primary" => {
                "id" => "arn:aws:elasticloadbalancing:ap-northeast-1:012345678901:loadbalancer/app/hoge/1234abcd1234abcd",
                "attributes" => {
                  "access_logs.#" => "1",
                  "access_logs.0.bucket" => "my-elb-logs",
                  "access_logs.0.prefix" => "hoge",
                  "access_logs.0.enabled" => "true",
                  "dns_name" => "hoge-123456789.ap-northeast-1.elb.amazonaws.com",
                  "enable_deletion_protection" => "false",
                  "id" => "arn:aws:elasticloadbalancing:ap-northeast-1:012345678901:loadbalancer/app/hoge/1234abcd1234abcd",
                  "idle_timeout" => "600",
                  "internal" => "false",
                  "name" => "hoge",
                  "security_groups.#" => "2",
                  "subnets.#" => "2",
                  "tags.%" => "1",
                  "tags.Environment" => "Production",
                  "zone_id" => "12345678ABCDEF",
                }
              }
            },
            "aws_alb.fuga" => {
              "type" => "aws_alb",
              "primary" => {
                "id" => "arn:aws:elasticloadbalancing:ap-northeast-1:012345678901:loadbalancer/app/fuga/5678efgh5678efgh",
                "attributes" => {
                  "access_logs.#" => "1",
                  "access_logs.0.bucket" => "my-elb-logs",
                  "access_logs.0.prefix" => "fuga",
                  "access_logs.0.enabled" => "false",
                  "dns_name" => "fuga-567891234.ap-northeast-1.elb.amazonaws.com",
                  "enable_deletion_protection" => "true",
                  "id" => "arn:aws:elasticloadbalancing:ap-northeast-1:012345678901:loadbalancer/app/fuga/5678efgh5678efgh",
                  "idle_timeout" => "60",
                  "internal" => "true",
                  "name" => "fuga",
                  "security_groups.#" => "1",
                  "subnets.#" => "2",
                  "tags.%" => "0",
                  "zone_id" => "12345678ABCDEF",
                }
              }
            }
          })
        end
      end
    end
  end
end

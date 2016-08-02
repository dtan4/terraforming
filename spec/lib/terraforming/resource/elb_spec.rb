require "spec_helper"

module Terraforming
  module Resource
    describe ELB do
      let(:client) do
        Aws::ElasticLoadBalancing::Client.new(stub_responses: true)
      end

      let(:load_balancer_descriptions) do
        [
          {
            subnets: [
              "subnet-1234abcd",
              "subnet-5678efgh"
            ],
            canonical_hosted_zone_name_id: "12345678ABCDEF",
            canonical_hosted_zone_name: "hoge-12345678.ap-northeast-1.elb.amazonaws.com",
            listener_descriptions: [
              {
                listener: {
                  instance_port: 80,
                  ssl_certificate_id: "arn:aws:iam::123456789012:server-certificate/foobar",
                  load_balancer_port: 443,
                  protocol: "HTTPS",
                  instance_protocol: "HTTP"
                },
                policy_names: [
                  "AWSConsole-SSLNegotiationPolicy-foobar-1234567890123"
                ]
              }
            ],
            health_check: {
              healthy_threshold: 10,
              interval: 30,
              target: "HTTP:8080/status",
              timeout: 5,
              unhealthy_threshold: 2
            },
            vpc_id: "vpc-1234abcd",
            backend_server_descriptions: [],
            instances: [
              {
                instance_id: "i-1234abcd"
              }
            ],
            dns_name: "hoge-12345678.ap-northeast-1.elb.amazonaws.com",
            security_groups: [
              "sg-1234abcd",
              "sg-5678efgh"
            ],
            policies: {
              lb_cookie_stickiness_policies: [],
              app_cookie_stickiness_policies: [],
              other_policies: [
                "ELBSecurityPolicy-2014-01",
                "AWSConsole-SSLNegotiationPolicy-foobar-1234567890123"
              ]
            },
            load_balancer_name: "hoge",
            created_time: Time.parse("2014-01-01T12:12:12.000Z"),
            availability_zones: [
              "ap-northeast-1b",
              "ap-northeast-1c"
            ],
            scheme: "internet-facing",
            source_security_group: {
              owner_alias: "123456789012",
              group_name: "default"
            }
          },
          {
            subnets: [
              "subnet-9012ijkl",
              "subnet-3456mnop"
            ],
            canonical_hosted_zone_name_id: "90123456GHIJKLM",
            canonical_hosted_zone_name: "fuga-90123456.ap-northeast-1.elb.amazonaws.com",
            listener_descriptions: [
              {
                listener: {
                  instance_port: 80,
                  ssl_certificate_id: "arn:aws:iam::345678901234:server-certificate/foobar",
                  load_balancer_port: 443,
                  protocol: "HTTPS",
                  instance_protocol: "HTTP"
                },
                policy_names: [
                  "AWSConsole-SSLNegotiationPolicy-foobar-1234567890123"
                ]
              }
            ],
            health_check: {
              healthy_threshold: 10,
              interval: 30,
              target: "HTTP:8080/status",
              timeout: 5,
              unhealthy_threshold: 2
            },
            vpc_id: "",
            backend_server_descriptions: [],
            instances: [
              {
                instance_id: "i-5678efgh"
              }
            ],
            dns_name: "fuga-90123456.ap-northeast-1.elb.amazonaws.com",
            security_groups: [
              "sg-9012ijkl",
              "sg-3456mnop"
            ],
            policies: {
              lb_cookie_stickiness_policies: [],
              app_cookie_stickiness_policies: [],
              other_policies: [
                "ELBSecurityPolicy-2014-01",
                "AWSConsole-SSLNegotiationPolicy-foobar-1234567890123"
              ]
            },
            load_balancer_name: "fuga",
            created_time: Time.parse("2015-01-01T12:12:12.000Z"),
            availability_zones: [
              "ap-northeast-1b",
              "ap-northeast-1c"
            ],
            scheme: "internal",
            source_security_group: {
              owner_alias: "345678901234",
              group_name: "elb"
            }
          }
        ]
      end

      let(:hoge_attributes) do
        {
          cross_zone_load_balancing: { enabled: true },
          access_log: { enabled: false },
          connection_draining: { enabled: true, timeout: 300 },
          connection_settings: { idle_timeout: 60 },
          additional_attributes: []
        }
      end

      let(:fuga_attributes) do
        {
          cross_zone_load_balancing: { enabled: true },
          access_log: {
            enabled: true,
            s3_bucket_name: "hoge-elb-logs",
            emit_interval: 60,
            s3_bucket_prefix: "fuga",
          },
          connection_draining: { enabled: true, timeout: 900 },
          connection_settings: { idle_timeout: 90 },
          additional_attributes: []
        }
      end

      let(:tag_attributes) do
        [{
          tags: [
            { key: 'name', value: 'elb-1' }
          ]
         }]
      end

      before do
        client.stub_responses(:describe_load_balancers, load_balancer_descriptions: load_balancer_descriptions)
        client.stub_responses(:describe_load_balancer_attributes, [
          { load_balancer_attributes: hoge_attributes },
          { load_balancer_attributes: fuga_attributes }
        ])
        client.stub_responses(:describe_tags, tag_descriptions: tag_attributes)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_elb" "hoge" {
    name                        = "hoge"
    subnets                     = ["subnet-1234abcd", "subnet-5678efgh"]
    security_groups             = ["sg-1234abcd", "sg-5678efgh"]
    instances                   = ["i-1234abcd"]
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 300
    internal                    = false

    listener {
        instance_port      = 80
        instance_protocol  = "http"
        lb_port            = 443
        lb_protocol        = "https"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/foobar"
    }

    health_check {
        healthy_threshold   = 10
        unhealthy_threshold = 2
        interval            = 30
        target              = "HTTP:8080/status"
        timeout             = 5
    }

    tags {
        "name" = "elb-1"
    }
}

resource "aws_elb" "fuga" {
    name                        = "fuga"
    availability_zones          = ["ap-northeast-1b", "ap-northeast-1c"]
    security_groups             = ["sg-9012ijkl", "sg-3456mnop"]
    instances                   = ["i-5678efgh"]
    cross_zone_load_balancing   = true
    idle_timeout                = 90
    connection_draining         = true
    connection_draining_timeout = 900
    internal                    = true

    access_logs {
        bucket        = "hoge-elb-logs"
        bucket_prefix = "fuga"
        interval      = 60
    }

    listener {
        instance_port      = 80
        instance_protocol  = "http"
        lb_port            = 443
        lb_protocol        = "https"
        ssl_certificate_id = "arn:aws:iam::345678901234:server-certificate/foobar"
    }

    health_check {
        healthy_threshold   = 10
        unhealthy_threshold = 2
        interval            = 30
        target              = "HTTP:8080/status"
        timeout             = 5
    }

    tags {
        "name" = "elb-1"
    }
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_elb.hoge" => {
              "type" => "aws_elb",
              "primary" => {
                "id" => "hoge",
                "attributes" => {
                  "access_logs.#" => "0",
                  "availability_zones.#" => "2",
                  "connection_draining" => "true",
                  "connection_draining_timeout" => "300",
                  "cross_zone_load_balancing" => "true",
                  "dns_name" => "hoge-12345678.ap-northeast-1.elb.amazonaws.com",
                  "id" => "hoge",
                  "idle_timeout" => "60",
                  "instances.#" => "1",
                  "internal" => "false",
                  "name" => "hoge",
                  "source_security_group" => "default",
                  "health_check.#" => "1",
                  "health_check.362345074.healthy_threshold" => "10",
                  "health_check.362345074.interval" => "30",
                  "health_check.362345074.target" => "HTTP:8080/status",
                  "health_check.362345074.timeout" => "5",
                  "health_check.362345074.unhealthy_threshold" => "2",
                  "listener.#" => "1",
                  "listener.3051874140.instance_port" => "80",
                  "listener.3051874140.instance_protocol" => "http",
                  "listener.3051874140.lb_port" => "443",
                  "listener.3051874140.lb_protocol" => "https",
                  "listener.3051874140.ssl_certificate_id" => "arn:aws:iam::123456789012:server-certificate/foobar", "security_groups.#" => "2",
                  "security_groups.550527283" => "sg-1234abcd",
                  "security_groups.3942994537" => "sg-5678efgh",
                  "subnets.#" => "2",
                  "subnets.3229571749" => "subnet-1234abcd",
                  "subnets.195717631" => "subnet-5678efgh",
                  "instances.3520380136" => "i-1234abcd",
                  "tags.#" => "1",
                  "tags.name" => "elb-1"
                }
              }
            },
            "aws_elb.fuga" => {
              "type" => "aws_elb",
              "primary" => {
                "id" => "fuga",
                "attributes" => {
                  "access_logs.#" => "1",
                  "access_logs.0.bucket" => "hoge-elb-logs",
                  "access_logs.0.bucket_prefix" => "fuga",
                  "access_logs.0.interval" => "60",
                  "availability_zones.#" => "2",
                  "connection_draining" => "true",
                  "connection_draining_timeout" => "900",
                  "cross_zone_load_balancing" => "true",
                  "dns_name" => "fuga-90123456.ap-northeast-1.elb.amazonaws.com",
                  "id" => "fuga",
                  "idle_timeout" => "90",
                  "instances.#" => "1",
                  "internal" => "true",
                  "name" => "fuga",
                  "source_security_group" => "elb",
                  "health_check.#" => "1",
                  "health_check.362345074.healthy_threshold" => "10",
                  "health_check.362345074.interval" => "30",
                  "health_check.362345074.target" => "HTTP:8080/status",
                  "health_check.362345074.timeout" => "5",
                  "health_check.362345074.unhealthy_threshold" => "2",
                  "listener.#" => "1",
                  "listener.1674021574.instance_port" => "80",
                  "listener.1674021574.instance_protocol" => "http",
                  "listener.1674021574.lb_port" => "443",
                  "listener.1674021574.lb_protocol" => "https",
                  "listener.1674021574.ssl_certificate_id" => "arn:aws:iam::345678901234:server-certificate/foobar",
                  "security_groups.#" => "2",
                  "security_groups.2877768809" => "sg-9012ijkl",
                  "security_groups.1478442660" => "sg-3456mnop",
                  "subnets.#" => "2",
                  "subnets.1260945407" => "subnet-9012ijkl",
                  "subnets.3098543410" => "subnet-3456mnop",
                  "instances.436309938" => "i-5678efgh",
                  "tags.#" => "1",
                  "tags.name" => "elb-1"
}
              }
            }
          })
        end
      end
    end
  end
end

require "spec_helper"

module Terraforming::Resource
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
          vpc_id: "vpc-5678efgh",
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
          scheme: "internet-facing",
          source_security_group: {
            owner_alias: "345678901234",
            group_name: "default"
          }
        }
      ]
    end

    before do
      client.stub_responses(:describe_load_balancers, load_balancer_descriptions: load_balancer_descriptions)
    end

    describe ".tf" do
      it "should generate tf" do
        expect(described_class.tf(client)).to eq <<-EOS
resource "aws_elb" "hoge" {
    name               = "hoge"
    availability_zones = ["ap-northeast-1b", "ap-northeast-1c"]
    subnets            = ["subnet-1234abcd", "subnet-5678efgh"]
    security_groups    = ["sg-1234abcd", "sg-5678efgh"]
    instances          = ["i-1234abcd"]

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
}

resource "aws_elb" "fuga" {
    name               = "fuga"
    availability_zones = ["ap-northeast-1b", "ap-northeast-1c"]
    subnets            = ["subnet-9012ijkl", "subnet-3456mnop"]
    security_groups    = ["sg-9012ijkl", "sg-3456mnop"]
    instances          = ["i-5678efgh"]

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
}

        EOS
      end
    end

    describe ".tfstate" do
      it "should generate tfstate" do
        expect(described_class.tfstate(client)).to eq JSON.pretty_generate({
          "aws_elb.hoge" => {
            "type" => "aws_elb",
            "primary" => {
              "id" => "hoge",
              "attributes" => {
                "availability_zones.#" => "2",
                "dns_name" => "hoge-12345678.ap-northeast-1.elb.amazonaws.com",
                "health_check.#" => "1",
                "id" => "hoge",
                "instances.#" => "1",
                "listener.#" => "1",
                "name" => "hoge",
                "security_groups.#" => "2",
                "subnets.#" => "2",
              }
            }
          },
          "aws_elb.fuga" => {
            "type" => "aws_elb",
            "primary" => {
              "id" => "fuga",
              "attributes" => {
                "availability_zones.#" => "2",
                "dns_name" => "fuga-90123456.ap-northeast-1.elb.amazonaws.com",
                "health_check.#" => "1",
                "id" => "fuga",
                "instances.#" => "1",
                "listener.#" => "1",
                "name" => "fuga",
                "security_groups.#" => "2",
                "subnets.#" => "2",
              }
            }
          }
        })
      end
    end
  end
end

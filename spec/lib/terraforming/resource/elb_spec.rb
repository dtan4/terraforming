require "spec_helper"

module Terraforming::Resource
  describe ELB do
    let(:json) do
      JSON.parse(open(fixture_path("elb/describe-load-balancers")).read)
    end

    describe ".tf" do
      it "should generate tf" do
        expect(described_class.tf(json)).to eq <<-EOS
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
        expect(described_class.tfstate(json)).to eq JSON.pretty_generate({
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

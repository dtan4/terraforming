require "spec_helper"

module Terraforming::Resource
  describe DBSubnetGroup do
    let(:json) do
      JSON.parse(open(fixture_path("rds/describe-db-subnet-groups")).read)
    end

    describe ".tf" do
      it "should generate tf" do
        expect(described_class.tf(json)).to eq <<-EOS
resource "aws_db_subnet_group" "hoge" {
    name        = "hoge"
    description = "DB subnet group hoge"
    subnet_ids  = ["subnet-1234abcd", "subnet-5678efgh"]
}

resource "aws_db_subnet_group" "fuga" {
    name        = "fuga"
    description = "DB subnet group fuga"
    subnet_ids  = ["subnet-9012ijkl", "subnet-3456mnop"]
}

        EOS
      end
    end

    describe ".tfstate" do
      xit "should generate tfstate" do
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

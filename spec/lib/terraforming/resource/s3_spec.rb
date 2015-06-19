require "spec_helper"

module Terraforming
  module Resource
    describe S3 do
      let(:buckets) do
        [
          {
            creation_date: Time.parse("2014-01-01T12:12:12.000Z"),
            name: "hoge"
          },
          {
            creation_date: Time.parse("2015-01-01T00:00:00.000Z"),
            name: "fuga"
          }
        ]
      end

      let(:client) do
        Aws::S3::Client.new(stub_responses: true)
      end

      let(:owner)  do
        {
          display_name: "owner",
          id: "12345678abcdefgh12345678abcdefgh12345678abcdefgh12345678abcdefgh"
        }
      end

      before do
        client.stub_responses(:list_buckets, buckets: buckets, owner: owner)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_s3_bucket" "hoge" {
    bucket = "hoge"
    acl    = "private"
}

resource "aws_s3_bucket" "fuga" {
    bucket = "fuga"
    acl    = "private"
}

        EOS
        end
      end

      describe ".tfstate" do
        context "without existing tfstate" do
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
                    "aws_s3_bucket.hoge" => {
                      "type" => "aws_s3_bucket",
                      "primary" => {
                        "id" => "hoge",
                        "attributes" => {
                          "acl" => "private",
                          "bucket" => "hoge",
                          "id" => "hoge"
                        }
                      }
                    },
                    "aws_s3_bucket.fuga" => {
                      "type" => "aws_s3_bucket",
                      "primary" => {
                        "id" => "fuga",
                        "attributes" => {
                          "acl" => "private",
                          "bucket" => "fuga",
                          "id" => "fuga"
                        }
                      }
                    }
                  }
                }
              ]
            })
          end
        end

        context "with existing tfstate" do
          it "should generate tfstate and merge it to existing tfstate" do
            expect(described_class.tfstate(client: client, tfstate_base: tfstate_fixture)).to eq JSON.pretty_generate({
              "version" => 1,
              "serial" => 89,
              "remote" => {
                "type" => "s3",
                "config" => { "bucket" => "terraforming-tfstate", "key" => "tf" }
              },
              "modules" => [
                {
                  "path" => ["root"],
                  "outputs" => {},
                  "resources" => {
                    "aws_elb.hogehoge" => {
                      "type" => "aws_elb",
                      "primary" => {
                        "id" => "hogehoge",
                        "attributes" => {
                          "availability_zones.#" => "2",
                          "connection_draining" => "true",
                          "connection_draining_timeout" => "300",
                          "cross_zone_load_balancing" => "true",
                          "dns_name" => "hoge-12345678.ap-northeast-1.elb.amazonaws.com",
                          "health_check.#" => "1",
                          "id" => "hogehoge",
                          "idle_timeout" => "60",
                          "instances.#" => "1",
                          "listener.#" => "1",
                          "name" => "hoge",
                          "security_groups.#" => "2",
                          "source_security_group" => "default",
                          "subnets.#" => "2"
                        }
                      }
                    },
                    "aws_s3_bucket.hoge" => {
                      "type" => "aws_s3_bucket",
                      "primary" => {
                        "id" => "hoge",
                        "attributes" => {
                          "acl" => "private",
                          "bucket" => "hoge",
                          "id" => "hoge"
                        }
                      }
                    },
                    "aws_s3_bucket.fuga" => {
                      "type" => "aws_s3_bucket",
                      "primary" => {
                        "id" => "fuga",
                        "attributes" => {
                          "acl" => "private",
                          "bucket" => "fuga",
                          "id" => "fuga"
                        }
                      }
                    },
                  }
                }
              ]
            })
          end
        end
      end
    end
  end
end

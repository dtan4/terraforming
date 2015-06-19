require "spec_helper"

module Terraforming
  module Resource
    describe IAMUser do
      let(:client) do
        Aws::IAM::Client.new(stub_responses: true)
      end

      let(:users) do
        [
          {
            path: "/",
            user_name: "hoge",
            user_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:user/hoge",
            create_date: Time.parse("2015-04-01 12:34:56 UTC"),
            password_last_used: Time.parse("2015-04-01 15:00:00 UTC"),
          },
          {
            path: "/system/",
            user_name: "fuga",
            user_id: "OPQRSTUVWXYZA8901234",
            arn: "arn:aws:iam::345678901234:user/fuga",
            create_date: Time.parse("2015-05-01 12:34:56 UTC"),
            password_last_used: Time.parse("2015-05-01 15:00:00 UTC"),
          },
        ]
      end

      before do
        client.stub_responses(:list_users, users: users)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_iam_user" "hoge" {
    name = "hoge"
    path = "/"
}

resource "aws_iam_user" "fuga" {
    name = "fuga"
    path = "/system/"
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
                    "aws_iam_user.hoge" => {
                      "type" => "aws_iam_user",
                      "primary" => {
                        "id" => "hoge",
                        "attributes" => {
                          "arn"=> "arn:aws:iam::123456789012:user/hoge",
                          "id" => "hoge",
                          "name" => "hoge",
                          "path" => "/",
                          "unique_id" => "ABCDEFGHIJKLMN1234567",
                        }
                      }
                    },
                    "aws_iam_user.fuga" => {
                      "type" => "aws_iam_user",
                      "primary" => {
                        "id" => "fuga",
                        "attributes" => {
                          "arn"=> "arn:aws:iam::345678901234:user/fuga",
                          "id" => "fuga",
                          "name" => "fuga",
                          "path" => "/system/",
                          "unique_id" => "OPQRSTUVWXYZA8901234",
                        }
                      }
                    },
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
              "serial" => 88,
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
                    "aws_iam_user.hoge" => {
                      "type" => "aws_iam_user",
                      "primary" => {
                        "id" => "hoge",
                        "attributes" => {
                          "arn"=> "arn:aws:iam::123456789012:user/hoge",
                          "id" => "hoge",
                          "name" => "hoge",
                          "path" => "/",
                          "unique_id" => "ABCDEFGHIJKLMN1234567",
                        }
                      }
                    },
                    "aws_iam_user.fuga" => {
                      "type" => "aws_iam_user",
                      "primary" => {
                        "id" => "fuga",
                        "attributes" => {
                          "arn"=> "arn:aws:iam::345678901234:user/fuga",
                          "id" => "fuga",
                          "name" => "fuga",
                          "path" => "/system/",
                          "unique_id" => "OPQRSTUVWXYZA8901234",
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

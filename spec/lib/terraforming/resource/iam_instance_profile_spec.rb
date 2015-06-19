require "spec_helper"

module Terraforming
  module Resource
    describe IAMInstanceProfile do
      let(:client) do
        Aws::IAM::Client.new(stub_responses: true)
      end

      let(:instance_profiles) do
        [
          {
            path: "/",
            instance_profile_name: "hoge_profile",
            instance_profile_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:instance-profile/hoge_profile",
            create_date: Time.parse("2015-04-01 12:34:56 UTC"),
            roles: [
              {
                path: "/",
                role_name: "hoge_role",
                role_id: "ABCDEFGHIJKLMN1234567",
                arn: "arn:aws:iam::123456789012:role/hoge_role",
                create_date: Time.parse("2015-04-01 12:34:56 UTC"),
                assume_role_policy_document: "%7B%22Version%22%3A%222008-10-17%22%2C%22Statement%22%3A%5B%7B%22Sid%22%3A%22%22%2C%22Effect%22%3A%22Allow%22%2C%22Principal%22%3A%7B%22Service%22%3A%22ec2.amazonaws.com%22%7D%2C%22Action%22%3A%22sts%3AAssumeRole%22%7D%5D%7D",
              },
            ],
          },
          {
            path: "/system/",
            instance_profile_name: "fuga_profile",
            instance_profile_id: "OPQRSTUVWXYZA8901234",
            arn: "arn:aws:iam::345678901234:instance-profile/fuga_profile",
            create_date: Time.parse("2015-05-01 12:34:56 UTC"),
            roles: [],
          },
        ]
      end

      before do
        client.stub_responses(:list_instance_profiles, instance_profiles: instance_profiles)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_iam_instance_profile" "hoge_profile" {
    name  = "hoge_profile"
    path  = "/"
    roles = ["hoge_role"]
}

resource "aws_iam_instance_profile" "fuga_profile" {
    name  = "fuga_profile"
    path  = "/system/"
    roles = []
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
                    "aws_iam_instance_profile.hoge_profile" => {
                      "type" => "aws_iam_instance_profile",
                      "primary" => {
                        "id" => "hoge_profile",
                        "attributes" => {
                          "arn"=> "arn:aws:iam::123456789012:instance-profile/hoge_profile",
                          "id" => "hoge_profile",
                          "name" => "hoge_profile",
                          "path" => "/",
                          "roles.#" => "1",
                        }
                      }
                    },
                    "aws_iam_instance_profile.fuga_profile" => {
                      "type" => "aws_iam_instance_profile",
                      "primary" => {
                        "id" => "fuga_profile",
                        "attributes" => {
                          "arn"=> "arn:aws:iam::345678901234:instance-profile/fuga_profile",
                          "id" => "fuga_profile",
                          "name" => "fuga_profile",
                          "path" => "/system/",
                          "roles.#" => "0",
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
                    "aws_iam_instance_profile.hoge_profile" => {
                      "type" => "aws_iam_instance_profile",
                      "primary" => {
                        "id" => "hoge_profile",
                        "attributes" => {
                          "arn"=> "arn:aws:iam::123456789012:instance-profile/hoge_profile",
                          "id" => "hoge_profile",
                          "name" => "hoge_profile",
                          "path" => "/",
                          "roles.#" => "1",
                        }
                      }
                    },
                    "aws_iam_instance_profile.fuga_profile" => {
                      "type" => "aws_iam_instance_profile",
                      "primary" => {
                        "id" => "fuga_profile",
                        "attributes" => {
                          "arn"=> "arn:aws:iam::345678901234:instance-profile/fuga_profile",
                          "id" => "fuga_profile",
                          "name" => "fuga_profile",
                          "path" => "/system/",
                          "roles.#" => "0",
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

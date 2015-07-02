require "spec_helper"

module Terraforming
  module Resource
    describe IAMGroupMembership do
      let(:client) do
        Aws::IAM::Client.new(stub_responses: true)
      end

      let(:groups) do
        [
          {
            path: "/",
            group_name: "hoge",
            group_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:group/hoge",
            create_date: Time.parse("2015-04-01 12:34:56 UTC"),
          },
          {
            path: "/system/",
            group_name: "fuga",
            group_id: "OPQRSTUVWXYZA8901234",
            arn: "arn:aws:iam::345678901234:group/fuga",
            create_date: Time.parse("2015-05-01 12:34:56 UTC"),
          },
        ]
      end

      let(:hoge_group) do
          {
            path: "/",
            group_name: "hoge",
            group_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:group/hoge",
            create_date: Time.parse("2015-04-01 12:34:56 UTC"),
          }
      end

      let(:hoge_users) do
        [
          {
            path: "/",
            user_name: "foo",
            user_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:user/foo",
            create_date: Time.parse("2015-04-01 12:34:56 UTC"),
            password_last_used: Time.parse("2015-04-01 15:00:00 UTC"),
          },
        ]
      end

      let(:fuga_group) do
          {
            path: "/system/",
            group_name: "fuga",
            group_id: "OPQRSTUVWXYZA8901234",
            arn: "arn:aws:iam::345678901234:group/fuga",
            create_date: Time.parse("2015-05-01 12:34:56 UTC"),
          }
      end

      let(:fuga_users) do
        [
          {
            path: "/system/",
            user_name: "bar",
            user_id: "OPQRSTUVWXYZA8901234",
            arn: "arn:aws:iam::345678901234:user/bar",
            create_date: Time.parse("2015-05-01 12:34:56 UTC"),
            password_last_used: Time.parse("2015-05-01 15:00:00 UTC"),
          },
        ]
      end

      before do
        client.stub_responses(:list_groups, groups: groups)
        client.stub_responses(:get_group, [{ group: hoge_group, users: hoge_users }, { group: fuga_group, users: fuga_users }])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_iam_group_membership" "hoge" {
    name  = "hoge-group-membership"
    users = ["foo"]
    group = "hoge"
}

resource "aws_iam_group_membership" "fuga" {
    name  = "fuga-group-membership"
    users = ["bar"]
    group = "fuga"
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
                    "aws_iam_group_membership.hoge" => {
                      "type" => "aws_iam_group_membership",
                      "primary" => {
                        "id" => "hoge-group-membership",
                        "attributes" => {
                          "group"=> "hoge",
                          "id" => "hoge-group-membership",
                          "name" => "hoge-group-membership",
                          "users.#" => "1",
                        }
                      }
                    },
                    "aws_iam_group_membership.fuga" => {
                      "type" => "aws_iam_group_membership",
                      "primary" => {
                        "id" => "fuga-group-membership",
                        "attributes" => {
                          "group"=> "fuga",
                          "id" => "fuga-group-membership",
                          "name" => "fuga-group-membership",
                          "users.#" => "1",
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
                    "aws_iam_group_membership.hoge" => {
                      "type" => "aws_iam_group_membership",
                      "primary" => {
                        "id" => "hoge-group-membership",
                        "attributes" => {
                          "group"=> "hoge",
                          "id" => "hoge-group-membership",
                          "name" => "hoge-group-membership",
                          "users.#" => "1",
                        }
                      }
                    },
                    "aws_iam_group_membership.fuga" => {
                      "type" => "aws_iam_group_membership",
                      "primary" => {
                        "id" => "fuga-group-membership",
                        "attributes" => {
                          "group"=> "fuga",
                          "id" => "fuga-group-membership",
                          "name" => "fuga-group-membership",
                          "users.#" => "1",
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

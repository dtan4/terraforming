require "spec_helper"

module Terraforming
  module Resource
    describe IAMAttachedPolicies do
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
        ]
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

      let(:roles) do
        [
          {
            path: "/",
            role_name: "hoge_role",
            role_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:role/hoge_role",
            create_date: Time.parse("2015-04-01 12:34:56 UTC"),
            assume_role_policy_document: "%7B%22Version%22%3A%222008-10-17%22%2C%22Statement%22%3A%5B%7B%22Sid%22%3A%22%22%2C%22Effect%22%3A%22Allow%22%2C%22Principal%22%3A%7B%22Service%22%3A%22ec2.amazonaws.com%22%7D%2C%22Action%22%3A%22sts%3AAssumeRole%22%7D%5D%7D",
          },
        ]
      end

      let(:hoge_policy) do
        {
          policy_name: "hoge_policy",
          policy_arn: "arn:aws:iam::123456789012:policy/hoge_policy",
        }
      end

      let(:fuga_policy) do
        {
          policy_name: "fuga_policy",
          policy_arn: "arn:aws:iam::345678901234:policy/fuga-policy",
        }
      end

      before do
        client.stub_responses(:list_users, users: users)
        client.stub_responses(:list_groups, groups: groups)
        client.stub_responses(:list_roles, roles: roles)
        client.stub_responses(:list_attached_user_policies, attached_policies: [fuga_policy])
        client.stub_responses(:list_attached_group_policies, attached_policies: [hoge_policy])
        client.stub_responses(:list_attached_role_policies, attached_policies: [hoge_policy, fuga_policy])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_iam_policy_attachment" "fuga_policy-attachments" {
    name       = "fuga_policy-attach"
    users      = ["hoge"]
    roles      = ["hoge_role"]
    groups     = []
    policy_arn = "arn:aws:iam::345678901234:policy/fuga-policy"
}

resource "aws_iam_policy_attachment" "hoge_policy-attachments" {
    name       = "hoge_policy-attach"
    users      = []
    roles      = ["hoge_role"]
    groups     = ["hoge","fuga"]
    policy_arn = "arn:aws:iam::123456789012:policy/hoge_policy"
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_iam_policy_attachment.fuga_policy-attachments" => {
              "type" => "aws_iam_policy_attachment",
              "primary" => {
                "id" => "fuga_policy-attach",
                "attributes" => {
                  "id" => "fuga_policy-attach",
                  "name" => "fuga_policy-attach",
                  "users.#" => "1",
                  "groups.#" => "0",
                  "roles.#" => "1",
                  "policy_arn" => "arn:aws:iam::345678901234:policy/fuga-policy",
                }
              }
            },
            "aws_iam_policy_attachment.hoge_policy-attachments" => {
              "type" => "aws_iam_policy_attachment",
              "primary" => {
                "id" => "hoge_policy-attach",
                "attributes" => {
                  "id" => "hoge_policy-attach",
                  "name" => "hoge_policy-attach",
                  "users.#" => "0",
                  "groups.#" => "2",
                  "roles.#" => "1",
                  "policy_arn" => "arn:aws:iam::123456789012:policy/hoge_policy",
                }
              }
            },
          })
        end
      end
    end
  end
end

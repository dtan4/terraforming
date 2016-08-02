require "spec_helper"

module Terraforming
  module Resource
    describe IAMPolicyAttachment do
      let(:client) do
        Aws::IAM::Client.new(stub_responses: true)
      end

      let(:policies) do
        [
          {
            policy_name: "hoge",
            policy_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:policy/hoge",
            path: "/",
            default_version_id: "v1",
            attachment_count: 0,
            is_attachable: true,
            create_date: Time.parse("2015-04-01 12:34:56 UTC"),
            update_date: Time.parse("2015-05-14 11:25:36 UTC"),
            description: "hoge",
          },
          {
            policy_name: "fuga",
            policy_id: "OPQRSTUVWXYZA8901234",
            arn: "arn:aws:iam::345678901234:policy/fuga",
            path: "/system/",
            default_version_id: "v1",
            attachment_count: 1,
            is_attachable: true,
            create_date: Time.parse("2015-04-01 12:00:00 UTC"),
            update_date: Time.parse("2015-04-26 19:54:56 UTC"),
            description: "fuga",
          }
        ]
      end

      let(:entities_for_policy_hoge) do
        {
          policy_groups: [
            { group_name: "hoge",  group_id: "GRUPEFGHIJKLMN1234567" },
            { group_name: "fuga",  group_id: "GRIPSTUVWXYZA89012345" },
          ],
          policy_users: [
            { user_name: "hoge", user_id: "USEREFGHIJKLMN1234567" }
          ],
          policy_roles: [],
        }
      end

      let(:entities_for_policy_fuga) do
        {
          policy_groups: [
            { group_name: "fuga", group_id: "GRIPSTUVWXYZA89012345" },
          ],
          policy_users: [
            { user_name: "hoge", user_id: "USEREFGHIJKLMN1234567" },
            { user_name: "fuga", user_id: "USERSTUVWXYZA89012345" },
          ],
          policy_roles: [
            { role_name: "hoge_role", role_id: "ROLEEFGHIJKLMN1234567" },
            { role_name: "fuga_role", role_id: "OPQRSTUVWXYZA89012345" },
          ],
        }
      end

      before do
        client.stub_responses(:list_policies, policies: policies)
        client.stub_responses(:list_entities_for_policy, [entities_for_policy_hoge, entities_for_policy_fuga])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_iam_policy_attachment" "hoge-policy-attachment" {
    name       = "hoge-policy-attachment"
    policy_arn = "arn:aws:iam::123456789012:policy/hoge"
    groups     = ["hoge", "fuga"]
    users      = ["hoge"]
    roles      = []
}

resource "aws_iam_policy_attachment" "fuga-policy-attachment" {
    name       = "fuga-policy-attachment"
    policy_arn = "arn:aws:iam::345678901234:policy/fuga"
    groups     = ["fuga"]
    users      = ["hoge", "fuga"]
    roles      = ["hoge_role", "fuga_role"]
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_iam_policy_attachment.hoge-policy-attachment" => {
              "type" => "aws_iam_policy_attachment",
              "primary" => {
                "id" => "hoge-policy-attachment",
                "attributes" => {
                  "id" => "hoge-policy-attachment",
                  "name" => "hoge-policy-attachment",
                  "policy_arn" => "arn:aws:iam::123456789012:policy/hoge",
                  "groups.#" => "2",
                  "users.#" => "1",
                  "roles.#" => "0",
                }
              }
            },
            "aws_iam_policy_attachment.fuga-policy-attachment" => {
              "type" => "aws_iam_policy_attachment",
              "primary" => {
                "id" => "fuga-policy-attachment",
                "attributes" => {
                  "id" => "fuga-policy-attachment",
                  "name" => "fuga-policy-attachment",
                  "policy_arn" => "arn:aws:iam::345678901234:policy/fuga",
                  "groups.#" => "1",
                  "users.#" => "2",
                  "roles.#" => "2",
                }
              }
            },
          })
        end
      end
    end
  end
end

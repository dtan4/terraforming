require "spec_helper"

module Terraforming
  module Resource
    describe IAMPolicy do
      let(:client) do
        Aws::IAM::Client.new(stub_responses: true)
      end

      let(:policies) do
        [
          {
            policy_name: "hoge_policy",
            policy_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:policy/hoge_policy",
            path: "/",
            default_version_id: "v1",
            attachment_count: 0,
            is_attachable: true,
            create_date: Time.parse("2015-04-01 12:34:56 UTC"),
            update_date: Time.parse("2015-05-14 11:25:36 UTC"),
            description: "hoge",
          },
          {
            policy_name: "fuga_policy",
            policy_id: "OPQRSTUVWXYZA8901234",
            arn: "arn:aws:iam::345678901234:policy/fuga-policy",
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

      let(:hoge_policy_version) do
        {
          document: "%7B%0A%20%20%22Version%22%3A%20%222012-10-17%22%2C%0A%20%20%22Statement%22%3A%20%5B%0A%20%20%20%20%7B%0A%20%20%20%20%20%20%22Action%22%3A%20%5B%0A%20%20%20%20%20%20%20%20%22ec2%3ADescribe%2A%22%0A%20%20%20%20%20%20%5D%2C%0A%20%20%20%20%20%20%22Effect%22%3A%20%22Allow%22%2C%0A%20%20%20%20%20%20%22Resource%22%3A%20%22%2A%22%0A%20%20%20%20%7D%0A%20%20%5D%0A%7D%0A",
          version_id: "v1",
          is_default_version: true,
          create_date: Time.parse("2015-05-14 11:25:36 UTC"),
        }
      end

      let(:fuga_policy_version) do
        {
          document: "%7B%0A%20%20%22Version%22%3A%20%222012-10-17%22%2C%0A%20%20%22Statement%22%3A%20%5B%0A%20%20%20%20%7B%0A%20%20%20%20%20%20%22Action%22%3A%20%5B%0A%20%20%20%20%20%20%20%20%22ec2%3ADescribe%2A%22%0A%20%20%20%20%20%20%5D%2C%0A%20%20%20%20%20%20%22Effect%22%3A%20%22Allow%22%2C%0A%20%20%20%20%20%20%22Resource%22%3A%20%22%2A%22%0A%20%20%20%20%7D%0A%20%20%5D%0A%7D%0A",
          version_id: "v1",
          is_default_version: true,
          create_date: Time.parse("2015-04-26 19:54:56 UTC"),
        }
      end

      before do
        client.stub_responses(:get_policy, [{ policy: policies[0] }, { policy: policies[1] }])
        client.stub_responses(:list_policies, policies: policies)
        client.stub_responses(:get_policy_version, [{ policy_version: hoge_policy_version }, { policy_version: fuga_policy_version }])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_iam_policy" "hoge_policy" {
    name        = "hoge_policy"
    path        = "/"
    description = "hoge"
    policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "fuga_policy" {
    name        = "fuga_policy"
    path        = "/system/"
    description = "fuga"
    policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_iam_policy.hoge_policy" => {
              "type" => "aws_iam_policy",
              "primary" => {
                "id" => "arn:aws:iam::123456789012:policy/hoge_policy",
                "attributes" => {
                  "id" => "arn:aws:iam::123456789012:policy/hoge_policy",
                  "name" => "hoge_policy",
                  "path" => "/",
                  "description" => "hoge",
                  "policy" => "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": [\n        \"ec2:Describe*\"\n      ],\n      \"Effect\": \"Allow\",\n      \"Resource\": \"*\"\n    }\n  ]\n}\n",
                }
              }
            },
            "aws_iam_policy.fuga_policy" => {
              "type" => "aws_iam_policy",
              "primary" => {
                "id" => "arn:aws:iam::345678901234:policy/fuga-policy",
                "attributes" => {
                  "id" => "arn:aws:iam::345678901234:policy/fuga-policy",
                  "name" => "fuga_policy",
                  "path" => "/system/",
                  "description" => "fuga",
                  "policy" => "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": [\n        \"ec2:Describe*\"\n      ],\n      \"Effect\": \"Allow\",\n      \"Resource\": \"*\"\n    }\n  ]\n}\n",
                }
              }
            },
          })
        end
      end
    end
  end
end

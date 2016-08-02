require "spec_helper"

module Terraforming
  module Resource
    describe IAMRole do
      let(:client) do
        Aws::IAM::Client.new(stub_responses: true)
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
          {
            path: "/system/",
            role_name: "fuga_role",
            role_id: "OPQRSTUVWXYZA8901234",
            arn: "arn:aws:iam::345678901234:role/fuga_role",
            create_date: Time.parse("2015-05-01 12:34:56 UTC"),
            assume_role_policy_document: "%7B%22Version%22%3A%222008-10-17%22%2C%22Statement%22%3A%5B%7B%22Sid%22%3A%221%22%2C%22Effect%22%3A%22Allow%22%2C%22Principal%22%3A%7B%22Service%22%3A%22elastictranscoder.amazonaws.com%22%7D%2C%22Action%22%3A%22sts%3AAssumeRole%22%7D%5D%7D",
          },
        ]
      end

      before do
        client.stub_responses(:list_roles, roles: roles)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_iam_role" "hoge_role" {
    name               = "hoge_role"
    path               = "/"
    assume_role_policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "fuga_role" {
    name               = "fuga_role"
    path               = "/system/"
    assume_role_policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": {
        "Service": "elastictranscoder.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
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
            "aws_iam_role.hoge_role" => {
              "type" => "aws_iam_role",
              "primary" => {
                "id" => "hoge_role",
                "attributes" => {
                  "arn" => "arn:aws:iam::123456789012:role/hoge_role",
                  "assume_role_policy" => "{\n  \"Version\": \"2008-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\"\n      },\n      \"Action\": \"sts:AssumeRole\"\n    }\n  ]\n}\n",
                  "id" => "hoge_role",
                  "name" => "hoge_role",
                  "path" => "/",
                  "unique_id" => "ABCDEFGHIJKLMN1234567",
                }
              }
            },
            "aws_iam_role.fuga_role" => {
              "type" => "aws_iam_role",
              "primary" => {
                "id" => "fuga_role",
                "attributes" => {
                  "arn" => "arn:aws:iam::345678901234:role/fuga_role",
                  "assume_role_policy" => "{\n  \"Version\": \"2008-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"1\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"elastictranscoder.amazonaws.com\"\n      },\n      \"Action\": \"sts:AssumeRole\"\n    }\n  ]\n}\n",
                  "id" => "fuga_role",
                  "name" => "fuga_role",
                  "path" => "/system/",
                  "unique_id" => "OPQRSTUVWXYZA8901234",
                }
              }
            },
          })
        end
      end
    end
  end
end

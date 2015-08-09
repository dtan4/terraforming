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

      let(:hoge_policy) do
        "{\"Version\":\"2012-10-17\",\"Id\":\"Policy123456789012\",\"Statement\":[{\"Sid\":\"Stmt123456789012\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::123456789012:user/hoge\"},\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::hoge/*\"}]}"
      end

      before do
        client.stub_responses(:list_buckets, buckets: buckets, owner: owner)
        client.stub_responses(:get_bucket_policy, [
          { policy: hoge_policy },
          "NoSuchBucketPolicy",
        ])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_s3_bucket" "hoge" {
    bucket = "hoge"
    acl    = "private"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "Policy123456789012",
  "Statement": [
    {
      "Sid": "Stmt123456789012",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/hoge"
      },
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::hoge/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "fuga" {
    bucket = "fuga"
    acl    = "private"
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_s3_bucket.hoge" => {
              "type" => "aws_s3_bucket",
              "primary" => {
                "id" => "hoge",
                "attributes" => {
                  "acl" => "private",
                  "bucket" => "hoge",
                  "id" => "hoge",
                  "policy" => "{\"Version\":\"2012-10-17\",\"Id\":\"Policy123456789012\",\"Statement\":[{\"Sid\":\"Stmt123456789012\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::123456789012:user/hoge\"},\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::hoge/*\"}]}",
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
                  "id" => "fuga",
                  "policy" => "",
                }
              }
            },
          })
        end
      end
    end
  end
end

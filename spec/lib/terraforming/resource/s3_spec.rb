require "spec_helper"

module Terraforming::Resource
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
        expect(described_class.tf(client)).to eq <<-EOS
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
      it "should generate tfstate" do
        expect(described_class.tfstate(client)).to eq JSON.pretty_generate({
          "version" => 1,
          "serial" => 1,
          "modules" => {
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
        })
      end
    end
  end
end

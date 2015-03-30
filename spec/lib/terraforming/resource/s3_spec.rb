require "spec_helper"

module Terraforming::Resource
  describe S3 do
    let(:json) do
      JSON.parse(open(fixture_path("s3api/list-buckets")).read)
    end

    describe ".tf" do
      it "should generate tf" do
        expect(described_class.tf(json)).to eq <<-EOS
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
        expect(described_class.tfstate(json)).to eq JSON.pretty_generate({
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
        })
      end
    end
  end
end

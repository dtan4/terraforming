require "spec_helper"

module Terraforming
  module Resource
    describe KMSAlias do
      let(:client) do
        Aws::KMS::Client.new(stub_responses: true)
      end

      let(:aliases) do
        [
          {
            alias_name: "alias/aws/acm",
            alias_arn: "arn:aws:kms:ap-northeast-1:123456789012:alias/aws/acm",
            target_key_id: "12ab34cd-56ef-12ab-34cd-12ab34cd56ef"
          },
          {
            alias_name: "alias/hoge",
            alias_arn: "arn:aws:kms:ap-northeast-1:123456789012:alias/hoge",
            target_key_id: "1234abcd-12ab-34cd-56ef-1234567890ab"
          },
          {
            alias_name: "alias/fuga",
            alias_arn: "arn:aws:kms:ap-northeast-1:123456789012:alias/fuga",
            target_key_id: "abcd1234-ab12-cd34-ef56-abcdef123456"
          },
        ]
      end

      before do
        client.stub_responses(:list_aliases, aliases: aliases)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_kms_alias" "hoge" {
    name          = "alias/hoge"
    target_key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"
}

resource "aws_kms_alias" "fuga" {
    name          = "alias/fuga"
    target_key_id = "abcd1234-ab12-cd34-ef56-abcdef123456"
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_kms_alias.hoge" => {
              "type" => "aws_kms_alias",
              "primary" => {
                "id" => "alias/hoge",
                "attributes" => {
                  "arn" => "arn:aws:kms:ap-northeast-1:123456789012:alias/hoge",
                  "id" => "alias/hoge",
                  "name" => "alias/hoge",
                  "target_key_id" => "1234abcd-12ab-34cd-56ef-1234567890ab",
                }
              }
            },
            "aws_kms_alias.fuga" => {
              "type" => "aws_kms_alias",
              "primary" => {
                "id" => "alias/fuga",
                "attributes" => {
                  "arn" => "arn:aws:kms:ap-northeast-1:123456789012:alias/fuga",
                  "id" => "alias/fuga",
                  "name" => "alias/fuga",
                  "target_key_id" => "abcd1234-ab12-cd34-ef56-abcdef123456",
                }
              }
            }
          })
        end
      end
    end
  end
end

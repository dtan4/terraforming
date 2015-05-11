require "spec_helper"

module Terraforming
  module Resource
    describe IAMGroup do
      let(:client) do
        Aws::IAM::Client.new(stub_responses: true)
      end

      let(:groups) do
        [
          {
            path: "/",
            group_name: "hoge",
            group_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:user/hoge",
            create_date: Time.parse("2015-04-01 12:34:56 UTC"),
          },
          {
            path: "/system/",
            group_name: "fuga",
            group_id: "OPQRSTUVWXYZA8901234",
            arn: "arn:aws:iam::345678901234:user/fuga",
            create_date: Time.parse("2015-05-01 12:34:56 UTC"),
          },
        ]
      end

      before do
        client.stub_responses(:list_groups, groups: groups)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client)).to eq <<-EOS
resource "aws_iam_group" "hoge" {
    name = "hoge"
    path = "/"
}

resource "aws_iam_group" "fuga" {
    name = "fuga"
    path = "/system/"
}

        EOS
        end
      end

      describe ".tfstate" do
        xit "should generate tfstate" do
          expect(described_class.tfstate(client)).to eq JSON.pretty_generate({
            "version" => 1,
            "serial" => 1,
            "modules" => {
              "path" => [
                "root"
              ],
              "outputs" => {},
              "resources" => {
                "aws_iam_user.hoge" => {
                  "type" => "aws_iam_user",
                  "primary" => {
                    "id" => "hoge",
                    "attributes" => {
                      "arn"=> "arn:aws:iam::123456789012:user/hoge",
                      "id" => "hoge",
                      "name" => "hoge",
                      "path" => "/",
                      "unique_id" => "ABCDEFGHIJKLMN1234567",
                    }
                  }
                },
                "aws_iam_user.fuga" => {
                  "type" => "aws_iam_user",
                  "primary" => {
                    "id" => "fuga",
                    "attributes" => {
                      "arn"=> "arn:aws:iam::345678901234:user/fuga",
                      "id" => "fuga",
                      "name" => "fuga",
                      "path" => "/system/",
                      "unique_id" => "OPQRSTUVWXYZA8901234",
                    }
                  }
                },
              }
            }
          })
        end
      end
    end
  end
end

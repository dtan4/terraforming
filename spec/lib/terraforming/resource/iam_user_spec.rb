require "spec_helper"

module Terraforming
  module Resource
    describe IAMUser do
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
          {
            path: "/system/",
            user_name: "fuga",
            user_id: "OPQRSTUVWXYZA8901234",
            arn: "arn:aws:iam::345678901234:user/fuga",
            create_date: Time.parse("2015-05-01 12:34:56 UTC"),
            password_last_used: Time.parse("2015-05-01 15:00:00 UTC"),
          },
        ]
      end

      before do
        client.stub_responses(:list_users, users: users)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client)).to eq <<-EOS
resource "aws_iam_user" "hoge" {
    name = "hoge"
    path = "/"
}

resource "aws_iam_user" "fuga" {
    name = "fuga"
    path = "/system/"
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client)).to eq JSON.pretty_generate({
            "version" => 1,
            "serial" => 1,
            "modules" => [
              {
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
            ]
          })
        end
      end
    end
  end
end

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

      before do
        client.stub_responses(:list_groups, [{
                                               groups: [groups[0]],
                                               is_truncated: true,
                                               marker: 'marker'
                                             }, {
                                               groups: [groups[1]],
                                               is_truncated: false,
                                               marker: nil
                                             }])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
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
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_iam_group.hoge" => {
              "type" => "aws_iam_group",
              "primary" => {
                "id" => "hoge",
                "attributes" => {
                  "arn" => "arn:aws:iam::123456789012:group/hoge",
                  "id" => "hoge",
                  "name" => "hoge",
                  "path" => "/",
                  "unique_id" => "ABCDEFGHIJKLMN1234567",
                }
              }
            },
            "aws_iam_group.fuga" => {
              "type" => "aws_iam_group",
              "primary" => {
                "id" => "fuga",
                "attributes" => {
                  "arn" => "arn:aws:iam::345678901234:group/fuga",
                  "id" => "fuga",
                  "name" => "fuga",
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

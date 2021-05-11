require "spec_helper"

module Terraforming
  module Resource
    describe CloudWatchLogGroup do
      let(:client) do
        Aws::CloudWatchLogs::Client.new(stub_responses: true)
      end

      let(:log_groups) do
        [
          {
            arn: "arn:aws:logs:region:account:log-group",
            creation_time: 1596223046916,
            kms_key_id: "fbe14984-fd9f-40d2-94ce-55d738d35daa",
            log_group_name: "Dummy Log Group 1",
            name_prefix: "DUMMY",
            metric_filter_count: 0,
            retention_in_days: 90,
            stored_bytes: 223
          },
          {
            arn: "arn:aws:logs:region:account:log-group",
            creation_time: 1596223046917,
            kms_key_id: "fbe14984-fd9f-40d2-94ce-55d738d35dab",
            log_group_name: "Dummy Log Group 2",
            name_prefix: "DUMMY",            
            metric_filter_count: 3,
            retention_in_days: 90,
            stored_bytes: 227
          }          
        ]
      end

    before do
      client.stub_responses(:describe_log_groups, log_groups: log_groups)
      todo client.stub_responses(:list_tags_log_group, [])

    end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_cloudwatch_log_group" "Dummy_Log_Group_1" {
  name                = "Dummy Log Group 1"
  name_prefix         = "DUMMY"
  retention_in_days   = 90
  kms_key_id          = "fbe14984-fd9f-40d2-94ce-55d738d35daa"
}
resource "aws_cloudwatch_log_group" "Dummy_Log_Group_2" {
  name                = "Dummy Log Group 2"
  name_prefix         = "DUMMY"
  retention_in_days   = 90
  kms_key_id          = "fbe14984-fd9f-40d2-94ce-55d738d35dab"
}
          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_cloudwatch_log_group.Dummy_Log_Group_1" => {
              "type" => "aws_cloudwatch_log_group",
              "primary" => {
                "id" => "arn:aws:logs:region:account:log-group",
                "attributes" => {
                  "name"              => "Dummy Log Group 1",
                  "name_prefix"       => "DUMMY",
                  "retention_in_days" => "90",
                  "kms_key_id"        => "fbe14984-fd9f-40d2-94ce-55d738d35daa"
                }
              }
            },
            "aws_cloudwatch_log_group.Dummy_Log_Group_2" => {
              "type" => "aws_cloudwatch_log_group",
              "primary" => {
                "id" => "arn:aws:logs:region:account:log-group",
                "attributes" => {
                  "name"              => "Dummy Log Group 2",
                  "name_prefix"       => "DUMMY",
                  "retention_in_days" => "90",
                  "kms_key_id"        => "fbe14984-fd9f-40d2-94ce-55d738d35dab"
                }
              }
            }
          })
        end
      end
    end
  end
end

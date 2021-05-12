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
            metric_filter_count: 0,
            retention_in_days: 90,
            stored_bytes: 227
          }
        ]
      end

    before do
      client.stub_responses(:describe_log_groups, log_groups: log_groups)
    end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_cloudwatch_log_group" "Dummy-Log-Group-1" {
    name                = "Dummy Log Group 1"
    retention_in_days   = "90"
    kms_key_id          = "fbe14984-fd9f-40d2-94ce-55d738d35daa"
}
          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq(
            {
              "primary" => {
                "attributes" => {
                  "arn"                 => "arn:aws:logs:region:account:log-group",
                  "creation_time"       => 1596223046916,
                  "kms_key_id"          => "fbe14984-fd9f-40d2-94ce-55d738d35daa",
                  "log_group_name"      => "Dummy Log Group 1",
                  "metric_filter_count" => 0,
                  "retention_in_days"   => 90,
                  "stored_bytes"        => 227
                },
                "id" => "Dummy Log Group 1"
              },
              "type" => "aws_cloudwatch_log_group"
            }
          )
        end
      end
    end
  end
end

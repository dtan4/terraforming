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
            id: "Dummy Log Group 1",
            name: "Dummy Log Group 1",
            name_prefix: "DUMMY",
            retention_in_days: 90,
            tags: ["Dummy Tag 1", "Dummy Tag 2"],
            arn: ["arn:aws:logs:region:account:log-group"]
          },
          {
            id: "Dummy Log Group 2",
            name: "Dummy Log Group 2",
            name_prefix: "DUMMY",
            retention_in_days: 90,
            tags: ["Dummy Tag 3", "Dummy Tag 4"],
            arn: ["arn:aws:logs:region:account:log-group"]
          }
        ]
      end

    #   before do
    #     client.stub_responses(:describe_log_groups, log_groups: log_groups)
    #   end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_cloudwatch_log_group" "Dummy Log Group 1" {
    name                = "Dummy Log Group 1"
    name_prefix         = "DUMMY"
    retention_in_days   = "90"
    tags                = ["Dummy Tag 1", "Dummy Tag 2"]
    arn                 = ["arn:aws:logs:region:account:log-group"]
}

resource "aws_cloudwatch_log_group" "Dummy Log Group 2" {
    name                = "Dummy Log Group 2"
    name_prefix         = "DUMMY"
    retention_in_days   = "90"
    tags                = ["Dummy Tag 3", "Dummy Tag 4"]
    arn                 = ["arn:aws:logs:region:account:log-group"]
}
          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_cloudwatch_log_group.Dummy-Log-Group-1" => {
              "type" => "aws_cloudwatch_log_group",
              "primary" => {
                "id" => "Dummy Log Group 1",
                "attributes" => {
                  "name" => "Dummy Log Group 1",
                  "name_prefix" => "DUMMY",
                  "retention_in_days" => "90",
                  "tags" => ["Dummy Tag 1", "Dummy Tag 2"],
                  "arn" => ["arn:aws:logs:region:account:log-group"]
                }
              }
            },
            "aws_cloudwatch_log_group.Dummy-Log-Group-2" => {
                "type" => "aws_cloudwatch_log_group",
                "primary" => {
                  "id" => "Dummy Log Group 2",
                  "attributes" => {
                    "name" => "Dummy Log Group 2",
                    "name_prefix" => "DUMMY",
                    "retention_in_days" => "90",
                    "tags" => ["Dummy Tag 3", "Dummy Tag 4"],
                    "arn" => ["arn:aws:logs:region:account:log-group"]
                  }
                }
            }
          })
        end
      end
    end
  end
end

require "spec_helper"

module Terraforming
  module Resource
    describe CloudWatchAlarm do
      let(:client) do
        Aws::CloudWatch::Client.new(stub_responses: true)
      end

      let(:alarms) do
        [
          {
            actions_enabled: true,
            alarm_actions: ["arn:aws:sns:region:account:lambda-alerts"],
            alarm_name: "Alarm With Dimensions",
            comparison_operator: "GreaterThanOrEqualToThreshold",
            dimensions: [{ name: "FunctionName", value: "beep-beep" }],
            evaluation_periods: 1,
            insufficient_data_actions: [],
            metric_name: "Duration",
            namespace: "AWS/Lambda",
            ok_actions: [],
            period: 300,
            statistic: "Average",
            threshold: 10000.0
          },
          {
            actions_enabled: false,
            alarm_actions: [],
            alarm_description: "This metric monitors ec2 cpu utilization",
            alarm_name: "terraform-test-foobar5",
            comparison_operator: "GreaterThanOrEqualToThreshold",
            evaluation_periods: 2,
            insufficient_data_actions: [],
            metric_name: "CPUUtilization",
            namespace: "AWS/EC2",
            ok_actions: [],
            period: 120,
            statistic: "Average",
            threshold: 80.0
          }
        ]
      end

      before do
        client.stub_responses(:describe_alarms, metric_alarms: alarms)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_cloudwatch_metric_alarm" "Alarm-With-Dimensions" {
    alarm_name          = "Alarm With Dimensions"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "1"
    metric_name         = "Duration"
    namespace           = "AWS/Lambda"
    period              = "300"
    statistic           = "Average"
    threshold           = "10000.0"
    alarm_description   = ""
    alarm_actions       = ["arn:aws:sns:region:account:lambda-alerts"]
    dimensions {
        FunctionName = "beep-beep"
    }
}

resource "aws_cloudwatch_metric_alarm" "terraform-test-foobar5" {
    alarm_name          = "terraform-test-foobar5"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "120"
    statistic           = "Average"
    threshold           = "80.0"
    alarm_description   = "This metric monitors ec2 cpu utilization"
    actions_enabled     = false
}

          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_cloudwatch_metric_alarm.Alarm-With-Dimensions" => {
              "type" => "aws_cloudwatch_metric_alarm",
              "primary" => {
                "id" => "Alarm With Dimensions",
                "attributes" => {
                  "actions_enabled" => "true",
                  "alarm_name" => "Alarm With Dimensions",
                  "alarm_description" => "",
                  "comparison_operator" => "GreaterThanOrEqualToThreshold",
                  "evaluation_periods" => "1",
                  "id" => "Alarm With Dimensions",
                  "metric_name" => "Duration",
                  "namespace" => "AWS/Lambda",
                  "ok_actions.#" => "0",
                  "period" => "300",
                  "statistic" => "Average",
                  "threshold" => "10000.0",
                  "unit" => "",
                  "insufficient_data_actions.#" => "0",
                  "alarm_actions.#" => "1",
                  "alarm_actions.1795058781" => "arn:aws:sns:region:account:lambda-alerts",
                  "dimensions.#" => "1",
                  "dimensions.FunctionName" => "beep-beep"
                }
              }
            },
            "aws_cloudwatch_metric_alarm.terraform-test-foobar5" => {
              "type" => "aws_cloudwatch_metric_alarm",
              "primary" => {
                "id" => "terraform-test-foobar5",
                "attributes" => {
                  "actions_enabled" => "false",
                  "alarm_description" => "This metric monitors ec2 cpu utilization",
                  "alarm_name" => "terraform-test-foobar5",
                  "comparison_operator" => "GreaterThanOrEqualToThreshold",
                  "evaluation_periods" => "2",
                  "id" => "terraform-test-foobar5",
                  "metric_name" => "CPUUtilization",
                  "namespace" => "AWS/EC2",
                  "ok_actions.#" => "0",
                  "period" => "120",
                  "statistic" => "Average",
                  "threshold" => "80.0",
                  "unit" => "",
                  "insufficient_data_actions.#" => "0",
                  "alarm_actions.#" => "0",
                  "dimensions.#" => "0"
                }
              }
            }
          })
        end
      end
    end
  end
end

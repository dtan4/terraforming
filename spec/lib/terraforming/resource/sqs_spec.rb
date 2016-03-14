require "spec_helper"

module Terraforming
  module Resource
    describe SQS do
      let(:client) do
        Aws::SQS::Client.new(stub_responses: true)
      end

      let(:queue_urls) do
        [
          "https://sqs.ap-northeast-1.amazonaws.com/123456789012/test",
        ]
      end

      let(:attributes) do
        {
          "QueueArn"                              => "arn:aws:sqs:ap-northeast-1:123456789012:test",
          "ApproximateNumberOfMessages"           => "0",
          "ApproximateNumberOfMessagesNotVisible" => "0",
          "ApproximateNumberOfMessagesDelayed"    => "0",
          "CreatedTimestamp"                      => "1456122200",
          "LastModifiedTimestamp"                 => "1456122200",
          "VisibilityTimeout"                     => "30",
          "MaximumMessageSize"                    => "262144",
          "MessageRetentionPeriod"                => "345600",
          "DelaySeconds"                          => "10",
          "ReceiveMessageWaitTimeSeconds"         => "10",
          "Policy"                                => "{\"Version\":\"2012-10-17\",\"Id\":\"arn:aws:sqs:ap-northeast-1:123456789012:test/SQSDefaultPolicy\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::987654321098:root\"},\"Action\":\"SQS:*\",\"Resource\":\"arn:aws:sqs:ap-northeast-1:123456789012:test\"}]}",
          "RedrivePolicy"                         => "{\"deadLetterTargetArn\":\"arn:aws:sqs:ap-northeast-1:123456789012:dead\",\"maxReceiveCount\":3}",
        }
      end

      before do
        client.stub_responses(:list_queues, queue_urls: queue_urls)
        client.stub_responses(:get_queue_attributes, attributes: attributes)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_sqs_queue" "test" {
    name                       = "test"
    visibility_timeout_seconds = 30
    message_retention_seconds  = 345600
    max_message_size           = 262144
    delay_seconds              = 10
    receive_wait_time_seconds  = 10
    policy                     = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "arn:aws:sqs:ap-northeast-1:123456789012:test/SQSDefaultPolicy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::987654321098:root"
      },
      "Action": "SQS:*",
      "Resource": "arn:aws:sqs:ap-northeast-1:123456789012:test"
    }
  ]
}
POLICY
    redrive_policy             = <<POLICY
{
  "deadLetterTargetArn": "arn:aws:sqs:ap-northeast-1:123456789012:dead",
  "maxReceiveCount": 3
}
POLICY
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_sqs_queue.test" => {
              "type" => "aws_sqs_queue",
              "primary" => {
                "id" => "https://sqs.ap-northeast-1.amazonaws.com/123456789012/test",
                "attributes" => {
                  "name"                       => "test",
                  "id"                         => "https://sqs.ap-northeast-1.amazonaws.com/123456789012/test",
                  "arn"                        => "arn:aws:sqs:ap-northeast-1:123456789012:test",
                  "visibility_timeout_seconds" => "30",
                  "message_retention_seconds"  => "345600",
                  "max_message_size"           => "262144",
                  "delay_seconds"              => "10",
                  "receive_wait_time_seconds"  => "10",
                  "policy"                     => "{\"Version\":\"2012-10-17\",\"Id\":\"arn:aws:sqs:ap-northeast-1:123456789012:test/SQSDefaultPolicy\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::987654321098:root\"},\"Action\":\"SQS:*\",\"Resource\":\"arn:aws:sqs:ap-northeast-1:123456789012:test\"}]}",
                  "redrive_policy"             => "{\"deadLetterTargetArn\":\"arn:aws:sqs:ap-northeast-1:123456789012:dead\",\"maxReceiveCount\":3}",
                }
              }
            }
          })
        end
      end
    end
  end
end

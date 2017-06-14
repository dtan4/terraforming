require "spec_helper"

module Terraforming
  module Resource
    describe SNSTopic do
      let(:client) do
        Aws::SNS::Client.new(stub_responses: true)
      end

      let(:topics) do
        [
            Aws::SNS::Types::Topic.new(topic_arn: "arn:aws:sns:us-west-2:012345678901:topicOfFanciness"),
        ]
      end

      let(:attributes) do
        {
          "SubscriptionsConfirmed"  => "1",
          "DisplayName"             => "topicOfFancinessDisplayName",
          "SubscriptionsDeleted"    => "0",
          "EffectiveDeliveryPolicy" => "{\"http\":{\"defaultHealthyRetryPolicy\":{\"minDelayTarget\":2,\"maxDelayTarget\":20,\"numRetries\":12,\"numMaxDelayRetries\":0,\"numNoDelayRetries\":0,\"numMinDelayRetries\":12,\"backoffFunction\":\"linear\"},\"disableSubscriptionOverrides\":false}}",
          "Owner"                   => "012345678901",
          "Policy"                  => "{\"Version\":\"2008-10-17\",\"Id\":\"__default_policy_ID\",\"Statement\":[{\"Sid\":\"__default_statement_ID\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"*\"},\"Action\":[\"SNS:GetTopicAttributes\",\"SNS:SetTopicAttributes\",\"SNS:AddPermission\",\"SNS:RemovePermission\",\"SNS:DeleteTopic\",\"SNS:Subscribe\",\"SNS:ListSubscriptionsByTopic\",\"SNS:Publish\",\"SNS:Receive\"],\"Resource\":\"arn:aws:sns:us-west-2:012345678901:topicOfFanciness\",\"Condition\":{\"StringEquals\":{\"AWS:SourceOwner\":\"012345678901\"}}}]}",
          "DeliveryPolicy"          => "{\"http\":{\"defaultHealthyRetryPolicy\":{\"minDelayTarget\":2,\"maxDelayTarget\":20,\"numRetries\":12,\"numMaxDelayRetries\":0,\"numNoDelayRetries\":0,\"numMinDelayRetries\":12,\"backoffFunction\":\"linear\"},\"disableSubscriptionOverrides\":false}}",
          "TopicArn"                => "arn:aws:sns:us-west-2:012345678901:topicOfFanciness",
          "SubscriptionsPending"    => "0"
        }
      end

      before do
        client.stub_responses(:list_topics, topics: topics)
        client.stub_responses(:get_topic_attributes, attributes: attributes)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_sns_topic" "topicOfFanciness" {
  name            = "topicOfFanciness"
  display_name    = "topicOfFancinessDisplayName"
  policy          = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish",
        "SNS:Receive"
      ],
      "Resource": "arn:aws:sns:us-west-2:012345678901:topicOfFanciness",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "012345678901"
        }
      }
    }
  ]
}
POLICY
  delivery_policy = <<POLICY
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 2,
      "maxDelayTarget": 20,
      "numRetries": 12,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 12,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false
  }
}
POLICY
}

EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_sns_topic.topicOfFanciness" => {
              "type" => "aws_sns_topic",
              "primary" => {
                "id" => "arn:aws:sns:us-west-2:012345678901:topicOfFanciness",
                "attributes" => {
                  "name"            => "topicOfFanciness",
                  "id"              => "arn:aws:sns:us-west-2:012345678901:topicOfFanciness",
                  "arn"             => "arn:aws:sns:us-west-2:012345678901:topicOfFanciness",
                  "display_name"    => "topicOfFancinessDisplayName",
                  "policy"          => "{\"Version\":\"2008-10-17\",\"Id\":\"__default_policy_ID\",\"Statement\":[{\"Sid\":\"__default_statement_ID\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"*\"},\"Action\":[\"SNS:GetTopicAttributes\",\"SNS:SetTopicAttributes\",\"SNS:AddPermission\",\"SNS:RemovePermission\",\"SNS:DeleteTopic\",\"SNS:Subscribe\",\"SNS:ListSubscriptionsByTopic\",\"SNS:Publish\",\"SNS:Receive\"],\"Resource\":\"arn:aws:sns:us-west-2:012345678901:topicOfFanciness\",\"Condition\":{\"StringEquals\":{\"AWS:SourceOwner\":\"012345678901\"}}}]}",
                  "delivery_policy" => "{\"http\":{\"defaultHealthyRetryPolicy\":{\"minDelayTarget\":2,\"maxDelayTarget\":20,\"numRetries\":12,\"numMaxDelayRetries\":0,\"numNoDelayRetries\":0,\"numMinDelayRetries\":12,\"backoffFunction\":\"linear\"},\"disableSubscriptionOverrides\":false}}"
                },
              },
            }
          })
        end
      end
    end
  end
end

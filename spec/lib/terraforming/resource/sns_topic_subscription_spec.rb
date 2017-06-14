require "spec_helper"

module Terraforming
  module Resource
    describe SNSTopicSubscription do
      let(:client) do
        Aws::SNS::Client.new(stub_responses: true)
      end

      let(:subscriptions) do
        [
            Aws::SNS::Types::Subscription.new(subscription_arn: "arn:aws:sns:us-west-2:012345678901:a-cool-topic:000ff1ce-dead-beef-f00d-ea7food5a1d1"),
            Aws::SNS::Types::Subscription.new(subscription_arn: "PendingConfirmation")
        ]
      end

      let(:attributes_regular) do
        {
          "Endpoint"                     => "arn:aws:sqs:us-west-2:012345678901:a-cool-queue",
          "Protocol"                     => "sqs",
          "RawMessageDelivery"           => "false",
          "ConfirmationWasAuthenticated" => "true",
          "Owner"                        => "012345678901",
          "SubscriptionArn"              => "arn:aws:sns:us-west-2:012345678901:a-cool-topic:000ff1ce-dead-beef-f00d-ea7food5a1d1",
          "TopicArn"                     => "arn:aws:sns:us-west-2:012345678901:a-cool-topic"
        }
      end

      let(:attributes_email) do
        {
          "Endpoint"                     => "arn:aws:sqs:us-west-2:012345678901:a-cool-queue",
          "Protocol"                     => "email-json",
          "RawMessageDelivery"           => "false",
          "ConfirmationWasAuthenticated" => "true",
          "Owner"                        => "012345678901",
          "SubscriptionArn"              => "arn:aws:sns:us-west-2:012345678901:a-cool-topic:000ff1ce-dead-beef-f00d-ea7food5a1d1",
          "TopicArn"                     => "arn:aws:sns:us-west-2:012345678901:a-cool-topic"
        }
      end

      before do
        client.stub_responses(:list_subscriptions, subscriptions: subscriptions)
        client.stub_responses(:get_subscription_attributes, attributes: attributes_regular)
      end

      describe ".tf" do
        it "should generate tf for non-email subscriptions" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_sns_topic_subscription" "000ff1ce-dead-beef-f00d-ea7food5a1d1" {
  topic_arn                       = "arn:aws:sns:us-west-2:012345678901:a-cool-topic"
  protocol                        = "sqs"
  endpoint                        = "arn:aws:sqs:us-west-2:012345678901:a-cool-queue"
  raw_message_delivery            = "false"
}

        EOS
        end
        it "should generate commented tf for email subscriptions" do
          client.stub_responses(:get_subscription_attributes, attributes: attributes_email)
          expect(described_class.tf(client: client)).to eq <<-EOS
/*
resource "aws_sns_topic_subscription" "000ff1ce-dead-beef-f00d-ea7food5a1d1" {
  topic_arn                       = "arn:aws:sns:us-west-2:012345678901:a-cool-topic"
  protocol                        = "email-json"
  endpoint                        = "arn:aws:sqs:us-west-2:012345678901:a-cool-queue"
  raw_message_delivery            = "false"
}
*/

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_sns_topic_subscription.000ff1ce-dead-beef-f00d-ea7food5a1d1" => {
              "type" => "aws_sns_topic_subscription",
              "primary" => {
                "id" => "arn:aws:sns:us-west-2:012345678901:a-cool-topic:000ff1ce-dead-beef-f00d-ea7food5a1d1",
                "attributes" => {
                  "id"                              => "arn:aws:sns:us-west-2:012345678901:a-cool-topic:000ff1ce-dead-beef-f00d-ea7food5a1d1",
                  "topic_arn"                       => "arn:aws:sns:us-west-2:012345678901:a-cool-topic",
                  "protocol"                        => "sqs",
                  "endpoint"                        => "arn:aws:sqs:us-west-2:012345678901:a-cool-queue",
                  "raw_message_delivery"            => "false",
                  "confirmation_timeout_in_minutes" => "1",
                  "endpoint_auto_confirms"          => "false"
                },
              },
            }
          })
        end
      end
    end
  end
end

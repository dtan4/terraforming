module Terraforming
  module Resource
    class SNSTopicSubscription
      include Terraforming::Util

      def self.tf(client: Aws::SNS::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::SNS::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/sns_topic_subscription")
      end

      def tfstate
        subscriptions.reject { |x| x["Protocol"].include?("email") }
                     .inject({}) do |resources, subscription|
          attributes = {
            "id"                              => subscription["SubscriptionArn"],
            "topic_arn"                       => subscription["TopicArn"],
            "protocol"                        => subscription["Protocol"],
            "endpoint"                        => subscription["Endpoint"],
            "raw_message_delivery"            =>
              subscription.key?("RawMessageDelivery") ? subscription["RawMessageDelivery"] : "false",
            "confirmation_timeout_in_minutes" =>
              subscription.key?("ConfirmationTimeoutInMinutes") ? subscription["ConfirmationTimeoutInMinutes"] : "1",
            "endpoint_auto_confirms"          =>
              subscription.key?("EndpointAutoConfirms") ? subscription["EndpointAutoConfirms"] : "false"
          }
          resources["aws_sns_topic_subscription.#{module_name_of(subscription)}"] = {
            "type" => "aws_sns_topic_subscription",
            "primary" => {
              "id"         => subscription["SubscriptionArn"],
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def subscriptions
        subscription_arns.map do |subscription_arn|
          # check explicitly for an issue with some subscriptions that returns ARN=PendingConfirmation
          next if subscription_arn == "PendingConfirmation"

          attributes = @client.get_subscription_attributes({
            subscription_arn: subscription_arn,
          }).attributes
          attributes["SubscriptionArn"] = subscription_arn
          attributes
        end.compact
      end

      def subscription_arns
        token = ""
        arns = []

        loop do
          resp = @client.list_subscriptions(next_token: token)
          arns += resp.subscriptions.map(&:subscription_arn).flatten
          token = resp.next_token
          break if token.nil?
        end

        arns
      end

      def module_name_of(subscription)
        normalize_module_name(subscription["SubscriptionArn"].split(":").last)
      end
    end
  end
end

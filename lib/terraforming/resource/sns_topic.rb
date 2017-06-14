module Terraforming
  module Resource
    class SNSTopic
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
        apply_template(@client, "tf/sns_topic")
      end

      def tfstate
        topics.inject({}) do |resources, topic|
          attributes = {
            "name"            => module_name_of(topic),
            "id"              => topic["TopicArn"],
            "arn"             => topic["TopicArn"],
            "display_name"    => topic["DisplayName"],
            "policy"          => topic.key?("Policy") ? topic["Policy"] : "",
            "delivery_policy" => topic.key?("DeliveryPolicy") ? topic["DeliveryPolicy"] : ""
          }
          resources["aws_sns_topic.#{module_name_of(topic)}"] = {
            "type" => "aws_sns_topic",
            "primary" => {
              "id"         => topic["TopicArn"],
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def topics
        topic_arns.map do |topic_arn|
          attributes = @client.get_topic_attributes({
            topic_arn: topic_arn,
          }).attributes
          attributes["TopicArn"] = topic_arn
          attributes
        end
      end

      def topic_arns
        token = ""
        arns = []

        loop do
          resp = @client.list_topics(next_token: token)
          arns += resp.topics.map(&:topic_arn).flatten
          token = resp.next_token
          break if token.nil?
        end

        arns
      end

      def module_name_of(topic)
        normalize_module_name(topic["TopicArn"].split(":").last)
      end
    end
  end
end

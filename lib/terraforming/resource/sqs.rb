module Terraforming
  module Resource
    class SQS
      include Terraforming::Util

      def self.tf(client: Aws::SQS::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::SQS::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/sqs")
      end

      def tfstate
        queues.inject({}) do |resources, queue|
          attributes = {
            "name"                       => module_name_of(queue),
            "id"                         => queue["QueueUrl"],
            "arn"                        => queue["QueueArn"],
            "visibility_timeout_seconds" => queue["VisibilityTimeout"],
            "message_retention_seconds"  => queue["MessageRetentionPeriod"],
            "max_message_size"           => queue["MaximumMessageSize"],
            "delay_seconds"              => queue["DelaySeconds"],
            "receive_wait_time_seconds"  => queue["ReceiveMessageWaitTimeSeconds"],
            "policy"                     => queue.key?("Policy") ? queue["Policy"] : "",
            "redrive_policy"             => queue.key?("RedrivePolicy") ? queue["RedrivePolicy"] : "",
          }
          resources["aws_sqs_queue.#{module_name_of(queue)}"] = {
            "type" => "aws_sqs_queue",
            "primary" => {
              "id"         => queue["QueueUrl"],
              "attributes" => attributes,
            }
          }

          resources
        end
      end

      private

      def queues
        queue_urls.map do |queue_url|
          attributes = @client.get_queue_attributes({
            queue_url: queue_url,
            attribute_names: ["All"],
          }).attributes
          attributes["QueueUrl"] = queue_url
          attributes
        end
      end

      def queue_urls
        @client.list_queues.map(&:queue_urls).flatten
      end

      def module_name_of(queue)
        normalize_module_name(queue["QueueArn"].split(":").last)
      end
    end
  end
end

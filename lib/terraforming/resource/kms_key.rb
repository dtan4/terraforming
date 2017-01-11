module Terraforming
  module Resource
    class KMSKey
      include Terraforming::Util

      def self.tf(client: Aws::KMS::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::KMS::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/kms_key")
      end

      def tfstate
        keys.inject({}) do |resources, key|
          resources["aws_kms_key.#{key.key_id}"] = {
            "type" => "aws_kms_key",
            "primary" => {
              "id" => key.key_id,
              "attributes" => {
                "arn" => key.arn,
                "description" => key.description,
                "enable_key_rotation" => key_rotation_status_of(key).key_rotation_enabled.to_s,
                "id" => key.key_id,
                "is_enabled" => key.enabled.to_s,
                "key_id" => key.key_id,
                "key_usage" => key_usage_of(key),
                "policy" => key_policy_of(key),
              },
            },
          }
          resources
        end
      end

      private

      def keys
        @client.list_keys.keys.map { |key| @client.describe_key(key_id: key.key_id) }.map(&:key_metadata)
      end

      def key_policy_of(key)
        policies = @client.list_key_policies(key_id: key.key_id).policy_names

        return "" if policies.length == 0

        @client.get_key_policy(key_id: key.key_id, policy_name: policies[0]).policy
      end

      def key_rotation_status_of(key)
        @client.get_key_rotation_status(key_id: key.key_id)
      end

      def key_usage_of(key)
        key.key_usage.gsub("_", "/")
      end
    end
  end
end
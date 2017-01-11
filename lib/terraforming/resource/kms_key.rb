module Terraforming
  module Resource
    class KMSKey
      include Terraforming::Util

      def self.tf(client: Aws::KMS::Client.new)
        self.new(client).tf
      end

      # TODO: Select appropriate Client class from here:
      # http://docs.aws.amazon.com/sdkforruby/api/index.html
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

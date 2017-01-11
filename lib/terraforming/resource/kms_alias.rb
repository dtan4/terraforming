module Terraforming
  module Resource
    class KMSAlias
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
        apply_template(@client, "tf/kms_alias")
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

      def aliases
        @client.list_aliases.aliases.reject { |als| managed_master_key_alias?(als) }
      end

      def managed_master_key_alias?(als)
        !!(als.alias_name =~ %r{\Aalias/aws/})
      end

      def module_name_of(als)
        normalize_module_name(als.alias_name.gsub(%r{\Aalias/}, ""))
      end
    end
  end
end

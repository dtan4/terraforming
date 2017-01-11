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
        aliases.inject({}) do |resources, als|
          resources["aws_kms_alias.#{module_name_of(als)}"] = {
            "type" => "aws_kms_alias",
            "primary" => {
              "id" => als.alias_name,
              "attributes" => {
                "arn" => als.alias_arn,
                "id" => als.alias_name,
                "name" => als.alias_name,
                "target_key_id" => als.target_key_id,
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
        als.alias_name =~ %r{\Aalias/aws/}
      end

      def module_name_of(als)
        normalize_module_name(als.alias_name.gsub(%r{\Aalias/}, ""))
      end
    end
  end
end

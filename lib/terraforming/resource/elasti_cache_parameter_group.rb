module Terraforming
  module Resource
    class ElastiCacheParameterGroup
      include Terraforming::Util

      def self.tf(client: Aws::ElastiCache::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::ElastiCache::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/elasti_cache_parameter_group")
      end

      def tfstate
        elasti_cache_parameter_groups.inject({}) do |resources, parameter_group|
          attributes = {
            "description" => parameter_group.description,
            "family" => parameter_group.cache_parameter_group_family,
            "id" => parameter_group.cache_parameter_group_name,
            "name" => parameter_group.cache_parameter_group_name,
            "parameter.#" => elasti_cache_parameters_in(parameter_group).length.to_s
          }
          resources["aws_elasticache_parameter_group.#{module_name_of(parameter_group)}"] = {
            "type" => "aws_elasticache_parameter_group",
            "primary" => {
              "id" => parameter_group.cache_parameter_group_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def elasti_cache_parameter_groups
        @client.describe_cache_parameter_groups.map(&:cache_parameter_groups).flatten
      end

      def elasti_cache_parameters_in(parameter_group)
        @client.describe_cache_parameters(cache_parameter_group_name: parameter_group.cache_parameter_group_name).map(&:parameters).flatten
      end

      def module_name_of(parameter_group)
        normalize_module_name(parameter_group.cache_parameter_group_name)
      end
    end
  end
end

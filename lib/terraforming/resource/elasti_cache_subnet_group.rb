module Terraforming
  module Resource
    class ElastiCacheSubnetGroup
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
        apply_template(@client, "tf/elasti_cache_subnet_group")
      end

      def tfstate
        cache_subnet_groups.inject({}) do |resources, cache_subnet_group|
          attributes = {
            "description" => cache_subnet_group.cache_subnet_group_description,
            "name" => cache_subnet_group.cache_subnet_group_name,
            "subnet_ids.#" => subnet_ids_of(cache_subnet_group).length.to_s,
          }
          resources["aws_elasticache_subnet_group.#{module_name_of(cache_subnet_group)}"] = {
            "type" => "aws_elasticache_subnet_group",
            "primary" => {
              "id" => cache_subnet_group.cache_subnet_group_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def cache_subnet_groups
        @client.describe_cache_subnet_groups.map(&:cache_subnet_groups).flatten
      end

      def subnet_ids_of(cache_subnet_group)
        cache_subnet_group.subnets.map { |sn| sn.subnet_identifier }
      end

      def module_name_of(cache_subnet_group)
        normalize_module_name(cache_subnet_group.cache_subnet_group_name)
      end
    end
  end
end

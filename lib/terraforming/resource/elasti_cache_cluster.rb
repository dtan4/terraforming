module Terraforming
  module Resource
    class ElastiCacheCluster
      include Terraforming::Util

      def self.tf(client: Aws::ElastiCache::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::ElastiCache::Client.new, tfstate_base: nil)
        self.new(client).tfstate(tfstate_base)
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/elasti_cache_cluster")
      end

      def tfstate(tfstate_base)
        resources = iam_groups.inject({}) do |result, group|
          attributes = {
            "arn"=> group.arn,
            "id" => group.group_name,
            "name" => group.group_name,
            "path" => group.path,
            "unique_id" => group.group_id,
          }
          result["aws_iam_group.#{group.group_name}"] = {
            "type" => "aws_iam_group",
            "primary" => {
              "id" => group.group_name,
              "attributes" => attributes
            }
          }

          result
        end

        generate_tfstate(resources, tfstate_base)
      end

      private

      def cache_clusters
        @client.describe_cache_clusters.cache_clusters
      end

      def cluster_in_vpc?(cache_cluster)
        cache_cluster.cache_security_groups.length == 0
      end

      def subnet_group_names_of(cache_cluster)
        cache_cluster.cache_security_groups.map { |sg| sg.cache_security_group_name }
      end

      def security_group_ids_of(cache_cluster)
        cache_cluster.security_groups.map { |sg| sg.security_group_id }
      end
    end
  end
end

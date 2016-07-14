module Terraforming
  module Resource
    class Redshift
      include Terraforming::Util

      def self.tf(client: Aws::Redshift::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::Redshift::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/redshift")
      end

      def tfstate
        clusters.inject({}) do |resources, cluster|
          attributes = {
            "cluster_identifier"                  => cluster.cluster_identifier,
            "cluster_type"                        => cluster.number_of_nodes == 1 ? "single-node" : "multi-node",
            "node_type"                           => cluster.node_type,
            "master_password"                     => "xxxxxxxx",
            "master_username"                     => cluster.master_username,
            "availability_zone"                   => cluster.availability_zone,
            "preferred_maintenance_window"        => cluster.preferred_maintenance_window,
            "cluster_parameter_group_name"        => cluster.cluster_parameter_groups[0].parameter_group_name,
            "automated_snapshot_retention_period" => cluster.automated_snapshot_retention_period.to_s,
            "port"                                => cluster.endpoint.port.to_s,
            "cluster_version"                     => cluster.cluster_version,
            "allow_version_upgrade"               => cluster.allow_version_upgrade.to_s,
            "number_of_nodes"                     => cluster.number_of_nodes.to_s,
            "publicly_accessible"                 => cluster.publicly_accessible.to_s,
            "encrypted"                           => cluster.encrypted.to_s,
            "skip_final_snapshot"                 => "true",
          }
          attributes["database_name"] = cluster.db_name if cluster.db_name

          resources["aws_redshift_cluster.#{module_name_of(cluster)}"] = {
            "type" => "aws_redshift_cluster",
            "primary" => {
              "id" => cluster.cluster_identifier,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def clusters
        @client.describe_clusters.map(&:clusters).flatten
      end

      def module_name_of(cluster)
        normalize_module_name(cluster.cluster_identifier)
      end
    end
  end
end

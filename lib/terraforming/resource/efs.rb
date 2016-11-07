module Terraforming
  module Resource
    class EFSFileSystem
      include Terraforming::Util

      def self.tf(client: Aws::EFS::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::EFS::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/elastic_filesystem")
      end

      def tfstate
        file_systems.inject({}) do |resources, efs|
          attributes = {
            "creation_token" => efs.creation_token,
            "id" => efs.file_system_id,
            "performance_mode" => efs.performance_mode,
            "tags.%" => "1",
            "tags.Name" => efs.name,
          }

          resources[format('%s',efs.file_system_id)] = {
            "type" => "aws_efs_file_system",
            "depends_on" => [],
            "primary" => {
              "id" => efs.file_system_id,
              "attributes" => attributes,
              "meta" => {},
              "tainted" => false,
            },
            "deposed" => [],
            "provider" => "aws",
          }

          resources
        end
      end

      private

      def file_systems
        @client.describe_file_systems.data.file_systems.flatten
      end
    end
  end
end

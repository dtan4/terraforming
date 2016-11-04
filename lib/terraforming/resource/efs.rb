# author: Jim Conner <snafu.x@gmail.com>
# Nov 2016
require 'awesome_print'
module Terraforming
  module Resource
    class EFS
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
        idx = -1

        efsystems.inject({}) do  |resources, efs|
          idx += 1

          attributes = {
            "creation_token" => efs.creation_token,
            "id" => efs.file_system_id,
            "performance_mode" => efs.performance_mode,
            "tags.%" => "1",
            "tags.Name" => efs.name,
          }

          resources["aws_efs_file_system.efs.#{idx}"] = {
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

      def efsystems
        @client.describe_file_systems.data.file_systems.flatten
      end
    end
  end
end

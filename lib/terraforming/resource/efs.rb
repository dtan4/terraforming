# author: Jim Conner <snafu.x@gmail.com>
# Nov 2016
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
        efsystems.inject({}) { |resources, _efs| resources }
      end

      private

      def efsystems
        @client.describe_file_systems.data.file_systems.flatten
      end
    end
  end
end

module Terraforming
  module Resource
    class CloudFrontDistribution
      include Terraforming::Util

      def self.tf(client: Aws::CloudFront::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::CloudFront::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/cloud_front_distribution")
      end

      private

      def distributions
        @client.list_distributions.distribution_list.items
      end
    end
  end
end

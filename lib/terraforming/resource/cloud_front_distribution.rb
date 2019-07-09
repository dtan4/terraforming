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

      def tfstate
        distributions.inject({}) do |resources, distribution|
          attributes = {
            "arn" => distribution.arn,
            "comment" => distribution.comment,
            "domain_name" => distribution.domain_name,
            "enabled" => distribution.enabled,
            "http_version" => distribution.http_version,
            "id" => distribution.id,
            "is_ipv6_enabled" => distribution.is_ipv6_enabled,
            "price_class" => distribution.price_class,
            "status" => distribution.status,
          }

          resources["aws_cloudfront_distribution.#{distribution.id}"] = {
            "type" => "aws_cloudfront_distribution",
            "primary" => {
              "id" => distribution.id,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def distributions
        @client.list_distributions.distribution_list.items
      end
    end
  end
end

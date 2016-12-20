module Terraforming
  module Resource
    class ALB
      include Terraforming::Util

      def self.tf(client: Aws::ElasticLoadBalancingV2::Client.new)
        self.new(client).tf
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/alb")
      end

      private

      def internal?(load_balancer)
        load_balancer.scheme == "internal"
      end

      def load_balancers
        @client.describe_load_balancers.load_balancers
      end

      def load_balancer_attributes_of(load_balancer)
        @client.describe_load_balancer_attributes(load_balancer_arn: load_balancer.load_balancer_arn).attributes.inject({}) do |result, attribute|
          result[attribute.key] = attribute.value
          result
        end
      end

      def module_name_of(load_balancer)
        normalize_module_name(load_balancer.load_balancer_name)
      end

      def tags_of(load_balancer)
        @client.describe_tags(resource_arns: [load_balancer.load_balancer_arn]).tag_descriptions.first.tags
      end
    end
  end
end

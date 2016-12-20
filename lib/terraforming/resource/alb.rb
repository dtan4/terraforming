module Terraforming
  module Resource
    class ALB
      include Terraforming::Util

      def self.tf(client: Aws::ElasticLoadBalancingV2::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::ElasticLoadBalancingV2::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/alb")
      end

      def tfstate
        load_balancers.inject({}) do |resources, load_balancer|
          load_balancer_attributes = load_balancer_attributes_of(load_balancer)
          attributes = {
            "dns_name" => load_balancer.dns_name,
            "enable_deletion_protection" => load_balancer_attributes["deletion_protection.enabled"].to_s,
            "id" => load_balancer.load_balancer_arn,
            "idle_timeout" => load_balancer_attributes["idle_timeout.timeout_seconds"].to_s,
            "internal" => internal?(load_balancer).to_s,
            "name" => load_balancer.load_balancer_name,
            "security_groups.#" => load_balancer.security_groups.length.to_s,
            "subnets.#" => load_balancer.availability_zones.length.to_s,
            "zone_id" => load_balancer.canonical_hosted_zone_id,
          }

          attributes.merge!(access_logs_attributes_of(load_balancer_attributes))
          attributes.merge!(tag_attributes_of(load_balancer))

          resources["aws_alb.#{module_name_of(load_balancer)}"] = {
            "type" => "aws_alb",
            "primary" => {
              "id" => load_balancer.load_balancer_arn,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def access_logs_attributes_of(load_balancer_attributes)
        {
          "access_logs.#" => "1",
          "access_logs.0.bucket" => load_balancer_attributes["access_logs.s3.bucket"],
          "access_logs.0.enabled" => load_balancer_attributes["access_logs.s3.enabled"].to_s,
          "access_logs.0.prefix" => load_balancer_attributes["access_logs.s3.prefix"],
        }
      end

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

      def tag_attributes_of(load_balancer)
        tags = tags_of(load_balancer)
        attributes = { "tags.%" => tags.length.to_s }

        tags.each do |tag|
          attributes["tags.#{tag.key}"] = tag.value
        end

        attributes
      end

      def tags_of(load_balancer)
        @client.describe_tags(resource_arns: [load_balancer.load_balancer_arn]).tag_descriptions.first.tags
      end
    end
  end
end

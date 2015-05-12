module Terraforming
  module Resource
    class ELB
      include Terraforming::Util

      def self.tf(client = Aws::ElasticLoadBalancing::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client = Aws::ElasticLoadBalancing::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/elb")
      end

      def tfstate
        resources = load_balancers.inject({}) do |result, load_balancer|
          attributes = {
            "availability_zones.#" => load_balancer.availability_zones.length.to_s,
            "dns_name" => load_balancer.dns_name,
            "health_check.#" => "1",
            "id" => load_balancer.load_balancer_name,
            "instances.#" => load_balancer.instances.length.to_s,
            "listener.#" => load_balancer.listener_descriptions.length.to_s,
            "name" => load_balancer.load_balancer_name,
            "security_groups.#" => load_balancer.security_groups.length.to_s,
            "subnets.#" => load_balancer.subnets.length.to_s,
          }
          result["aws_elb.#{module_name_of(load_balancer)}"] = {
            "type" => "aws_elb",
            "primary" => {
              "id" => load_balancer.load_balancer_name,
              "attributes" => attributes
            }
          }

          result
        end

        generate_tfstate(resources)
      end

      def load_balancers
        @client.describe_load_balancers.load_balancer_descriptions
      end

      def load_balancer_attributes_of(load_balancer)
        @client.describe_load_balancer_attributes(load_balancer_name: load_balancer.load_balancer_name).load_balancer_attributes
      end

      def module_name_of(load_balancer)
        normalize_module_name(load_balancer.load_balancer_name)
      end
    end
  end
end

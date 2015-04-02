module Terraforming::Resource
  class ELB
    def self.tf(client = Aws::ElasticLoadBalancing::Client.new)
      ERB.new(open(Terraforming.template_path("tf/elb")).read, nil, "-").result(binding)
    end

    def self.tfstate(client = Aws::ElasticLoadBalancing::Client.new)
      tfstate_db_instances = client.describe_load_balancers.load_balancer_descriptions.inject({}) do |result, load_balancer|
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

        result["aws_elb.#{load_balancer.load_balancer_name}"] = {
          "type" => "aws_elb",
          "primary" => {
            "id" => load_balancer.load_balancer_name,
            "attributes" => attributes
          }
        }
        result
      end

      JSON.pretty_generate(tfstate_db_instances)
    end
  end
end

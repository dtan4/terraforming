module Terraforming::Resource
  class ELB
    def self.tf(data)
      ERB.new(open(Terraforming.template_path("tf/elb")).read, nil, "-").result(binding)
    end

    def self.tfstate(data)
      tfstate_db_instances = data['LoadBalancerDescriptions'].inject({}) do |result, load_balancer|
        attributes = {
          "availability_zones.#" => load_balancer['AvailabilityZones'].length.to_s,
          "dns_name" => load_balancer['DNSName'],
          "health_check.#" => "1",
          "id" => load_balancer['LoadBalancerName'],
          "instances.#" => load_balancer['Instances'].length.to_s,
          "listener.#" => load_balancer['ListenerDescriptions'].length.to_s,
          "name" => load_balancer['LoadBalancerName'],
          "security_groups.#" => load_balancer['SecurityGroups'].length.to_s,
          "subnets.#" => load_balancer['Subnets'].length.to_s,
        }

        result["aws_elb.#{load_balancer['LoadBalancerName']}"] = {
          "type" => "aws_elb",
          "primary" => {
            "id" => load_balancer['LoadBalancerName'],
            "attributes" => attributes
          }
        }
        result
      end

      JSON.pretty_generate(tfstate_db_instances)
    end
  end
end

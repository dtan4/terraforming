module Terraforming::Resource
  class VPC
    def self.tf(client = Aws::EC2::Client.new)
      Terraforming::Resource.apply_template(client, "tf/vpc")
    end

    def self.tfstate(client = Aws::EC2::Client.new)
      resources = client.describe_vpcs.vpcs.inject({}) do |result, vpc|
        attributes = {
          "cidr_block" => vpc.cidr_block,
          "id" => vpc.vpc_id,
          "instance_tenancy" => vpc.instance_tenancy,
          "tags.#" => vpc.tags.length.to_s,
        }
        result["aws_vpc.#{Terraforming::Resource.name_from_tag(vpc, vpc.vpc_id)}"] = {
          "type" => "aws_vpc",
          "primary" => {
            "id" => vpc.vpc_id,
            "attributes" => attributes
          }
        }

        result
      end

      Terraforming::Resource.tfstate(resources)
    end
  end
end

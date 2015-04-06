module Terraforming::Resource
  class VPC
    def self.tf(client = Aws::EC2::Client.new)
      Terraforming::Resource.apply_template(client, "tf/vpc")
    end

    def self.tfstate(data)
      tfstate_db_instances = data['Vpcs'].inject({}) do |result, vpc|
        attributes = {
          "cidr_block" => vpc['CidrBlock'],
          "id" => vpc['VpcId'],
          "instance_tenancy" => vpc['InstanceTenancy'],
          "tags.#" => vpc['Tags'].length.to_s,
        }

        result["aws_vpc.#{vpc_name_of(vpc)}"] = {
          "type" => "aws_vpc",
          "primary" => {
            "id" => vpc['VpcId'],
            "attributes" => attributes
          }
        }
        result
      end

      JSON.pretty_generate(tfstate_db_instances)
    end
  end
end

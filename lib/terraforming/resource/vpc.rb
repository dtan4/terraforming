module Terraforming::Resource
  class VPC
    def self.vpc_name_of(vpc)
      name_tag = vpc['Tags'].find { |tag| tag['Key'] == "Name" }
      name_tag ? name_tag['Value'] : vpc['VpcId']
    end

    def self.tf(data)
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

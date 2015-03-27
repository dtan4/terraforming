module Terraforming::Resource
  class VPC
    def self.vpc_name_of(vpc)
      name_tag = vpc['Tags'].find { |tag| tag['Key'] == "Name" }
      name_tag ? name_tag['Value'] : vpc['VpcId']
    end

    def self.tf(data)
      data['Vpcs'].inject([]) do |result, vpc|
        tags = vpc['Tags'].map do |tag|
      <<-EOS
        #{tag['Key']} = "#{tag['Value']}"
      EOS
        end.join("\n")

        result << <<-EOS
resource "aws_vpc" "#{vpc_name_of(vpc)}" {
    cidr_block       = "#{vpc['CidrBlock']}"
    instance_tenancy = "#{vpc['InstanceTenancy']}"

    tags {
#{tags}
    }
}
    EOS
      end.join("\n")
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

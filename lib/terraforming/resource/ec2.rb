module Terraforming::Resource
  class EC2
    def self.tf(client = Aws::EC2::Client.new)
      Terraforming::Resource.apply_template(client, "tf/ec2")
    end

    def self.tfstate(client = Aws::EC2::Client.new)
      resources = client.describe_instances.reservations.map(&:instances).flatten.inject({}) do |result, instance|
        attributes = {
          "ami"=> instance.image_id,
          "associate_public_ip_address"=> "true",
          "availability_zone"=> instance.placement.availability_zone,
          "ebs_block_device.#"=> instance.block_device_mappings.length.to_s,
          "ebs_optimized"=> instance.ebs_optimized.to_s,
          "ephemeral_block_device.#"=> "0",
          "id"=> instance.instance_id,
          "instance_type"=> instance.instance_type,
          "private_dns"=> instance.private_dns_name,
          "private_ip"=> instance.private_ip_address,
          "public_dns"=> instance.public_dns_name,
          "public_ip"=> instance.public_ip_address,
          "root_block_device.#"=> instance.root_device_name ? "1" : "0",
          "security_groups.#"=> instance.security_groups.length.to_s,
          "source_dest_check"=> instance.source_dest_check.to_s,
          "subnet_id"=> instance.subnet_id,
          "tenancy"=> instance.placement.tenancy
        }
        result["aws_instance.#{Terraforming::Resource.name_from_tag(instance, instance.instance_id)}"] = {
          "type" => "aws_instance",
          "primary" => {
            "id" => instance.instance_id,
            "attributes" => attributes,
            "meta" => {
              "schema_version" => "1"
            }
          }
        }

        result
      end

      tfstate =  {
        "version" => 1,
        "serial" => 84,
        "modules" => {
          "path" => [
            "root"
          ],
          "outputs" => {},
          "resources" => resources
        }
      }

      JSON.pretty_generate(tfstate)
    end
  end
end

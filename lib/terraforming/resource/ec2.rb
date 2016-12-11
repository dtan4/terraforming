module Terraforming
  module Resource
    class EC2
      include Terraforming::Util

      def self.tf(client: Aws::EC2::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::EC2::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/ec2")
      end

      def tfstate
        instances.inject({}) do |resources, instance|
          in_vpc = in_vpc?(instance)
          block_devices = block_devices_of(instance)

          attributes = {
            "ami" => instance.image_id,
            "associate_public_ip_address" => associate_public_ip?(instance).to_s,
            "availability_zone" => instance.placement.availability_zone,
            "ebs_block_device.#" => ebs_block_devices_in(block_devices, instance).length.to_s,
            "ebs_optimized" => instance.ebs_optimized.to_s,
            "ephemeral_block_device.#" => "0", # Terraform 0.6.1 cannot fetch this field from AWS
            "id" => instance.instance_id,
            "instance_type" => instance.instance_type,
            "monitoring" => monitoring_state(instance).to_s,
            "private_dns" => instance.private_dns_name,
            "private_ip" => instance.private_ip_address,
            "public_dns" => instance.public_dns_name,
            "public_ip" => instance.public_ip_address,
            "root_block_device.#" => root_block_devices_in(block_devices, instance).length.to_s,
            "security_groups.#" => in_vpc ? "0" : instance.security_groups.length.to_s,
            "source_dest_check" => instance.source_dest_check.to_s,
            "tenancy" => instance.placement.tenancy,
            "vpc_security_group_ids.#" => in_vpc ? instance.security_groups.length.to_s : "0",
          }

          placement_group = instance.placement.group_name
          attributes["placement_group"] = placement_group unless placement_group.empty?

          attributes["subnet_id"] = instance.subnet_id if in_vpc?(instance)

          resources["aws_instance.#{module_name_of(instance)}"] = {
            "type" => "aws_instance",
            "primary" => {
              "id" => instance.instance_id,
              "attributes" => attributes,
              "meta" => {
                "schema_version" => "1"
              }
            }
          }

          resources
        end
      end

      private

      def block_device_ids_of(instance)
        instance.block_device_mappings.map { |bdm| bdm.ebs.volume_id }
      end

      def block_devices_of(instance)
        return [] if instance.block_device_mappings.empty?
        @client.describe_volumes(volume_ids: block_device_ids_of(instance)).map(&:volumes).flatten
      end

      def block_device_mapping_of(instance, volume_id)
        instance.block_device_mappings.select { |bdm| bdm.ebs.volume_id == volume_id }[0]
      end

      def ebs_block_devices_in(block_devices, instance)
        block_devices.reject do |bd|
          root_block_device?(block_device_mapping_of(instance, bd.volume_id), instance)
        end
      end

      #
      # NOTE(dtan4):
      #   Original logic is here:
      #     https://github.com/hashicorp/terraform/blob/281e4d3e67f66daab9cdb1f7c8b6f602d949e5ee/builtin/providers/aws/resource_aws_instance.go#L481-L501
      #
      def in_vpc?(instance)
        !vpc_security_groups_of(instance).empty? ||
          (instance.subnet_id && instance.subnet_id != "" && instance.security_groups.empty?)
      end

      def associate_public_ip?(instance)
        !instance.public_ip_address.to_s.empty?
      end

      def monitoring_state(instance)
        %w(enabled pending).include?(instance.monitoring.state)
      end

      def instances
        @client.describe_instances.map(&:reservations).flatten.map(&:instances).flatten.reject do |instance|
          instance.state.name == "terminated"
        end
      end

      def module_name_of(instance)
        normalize_module_name(name_from_tag(instance, instance.instance_id))
      end

      def root_block_device?(block_device_mapping, instance)
        block_device_mapping.device_name == instance.root_device_name
      end

      def root_block_devices_in(block_devices, instance)
        block_devices.select { |bd| root_block_device?(block_device_mapping_of(instance, bd.volume_id), instance) }
      end

      def vpc_security_groups_of(instance)
        instance.security_groups.select { |security_group| /\Asg-/ =~ security_group.group_id }
      end
    end
  end
end

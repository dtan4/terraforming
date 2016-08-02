module Terraforming
  module Resource
    class LaunchConfiguration
      include Terraforming::Util

      def self.tf(client: Aws::AutoScaling::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::AutoScaling::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/launch_configuration")
      end

      def tfstate
        launch_configurations.inject({}) do |resources, lc|
          attributes = {
            "name" => lc.launch_configuration_name,
            "image_id" => lc.image_id,
            "instance_type" => lc.instance_type,
            "key_name" => lc.key_name,
            "security_groups.#" => lc.security_groups.length.to_s,
            "associate_public_ip_address" => lc.associate_public_ip_address.to_s,
            "user_data" => lc.user_data,
            "enable_monitoring" => lc.instance_monitoring.enabled.to_s,
            "ebs_optimized" => lc.ebs_optimized.to_s,
            "root_block_device.#" => root_block_device_count(lc).to_s,
            "ebs_block_device.#" => ebs_block_device_count(lc).to_s,
            "ephemeral_block_device.#" => ephemeral_block_device_count(lc).to_s
          }

          lc.security_groups.each do |sg|
            hash = hash_security_group(sg)
            attributes["security_groups.#{hash}"] = sg
          end

          attributes["iam_instance_profile"] = lc.iam_instance_profile if lc.iam_instance_profile
          attributes["spot_price"] = lc.spot_price if lc.spot_price
          attributes["placement_tenancy"] = lc.placement_tenancy if lc.placement_tenancy

          resources["aws_launch_configuration.#{module_name_of(lc)}"] = {
            "type" => "aws_launch_configuration",
            "primary" => {
              "id" => lc.launch_configuration_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      # Taken from http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
      def root_block_device?(block_device)
        %w(/dev/sda1 /dev/xvda).include? block_device.device_name
      end

      def root_block_device_count(launch_configuration)
        launch_configuration.block_device_mappings.select do |volume|
          root_block_device?(volume)
        end.length
      end

      def ebs_block_device?(block_device)
        block_device.virtual_name.nil? && block_device.ebs
      end

      def ebs_block_device_count(launch_configuration)
        launch_configuration.block_device_mappings.select do |volume|
          ebs_block_device?(volume) && !root_block_device?(volume)
        end.length
      end

      def ephemeral_block_device?(block_device)
        block_device.virtual_name != nil
      end

      def ephemeral_block_device_count(launch_configuration)
        launch_configuration.block_device_mappings.select do |volume|
          ephemeral_block_device?(volume)
        end.length
      end

      def hash_security_group(name)
        Zlib.crc32(name)
      end

      def launch_configurations
        @client.describe_launch_configurations.map(&:launch_configurations).flatten
      end

      def module_name_of(launch_configuration)
        normalize_module_name(launch_configuration.launch_configuration_name)
      end
    end
  end
end

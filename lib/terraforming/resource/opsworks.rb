module Terraforming
  module Resource
    class OpsWorks
      include Terraforming::Util

      def self.tf(client: Aws::OpsWorks::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::OpsWorks::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/opsworks")
      end

      def tfstate
        stacks.inject({}) do |resources, stack|
          attributes = {
            "color"                            => stack.attributes["Color"],
            "default_availability_zone"        => stack.default_availability_zone,
            "default_instance_profile_arn"     => stack.default_instance_profile_arn,
            "default_os"                       => stack.default_os,
            "default_root_device_type"         => stack.default_root_device_type,
            "default_ssh_key_name"             => stack.default_ssh_key_name,
            "default_subnet_id"                => stack.default_subnet_id,
            "hostname_theme"                   => stack.hostname_theme,
            "name"                             => stack.name,
            "region"                           => stack.region,
            "service_role_arn"                 => stack.service_role_arn,
            "use_custom_cookbooks"             => stack.use_custom_cookbooks.to_s,
            "use_opsworks_security_groups"     => stack.use_opsworks_security_groups.to_s,
            "vpc_id"                           => stack.vpc_id,

            "configuration_manager_name"       => stack.configuration_manager.name,
            "configuration_manager_version"    => stack.configuration_manager.version,

            "berkshelf_version"                => stack.chef_configuration.berkshelf_version,
            "manage_berkshelf"                 => stack.chef_configuration.manage_berkshelf.to_s,

            "custom_cookbooks_source.password" => stack.custom_cookbooks_source.password,
            "custom_cookbooks_source.revision" => stack.custom_cookbooks_source.revision,
            "custom_cookbooks_source.ssh_key"  => stack.custom_cookbooks_source.ssh_key,
            "custom_cookbooks_source.type"     => stack.custom_cookbooks_source.type,
            "custom_cookbooks_source.url"      => stack.custom_cookbooks_source.url,
            "custom_cookbooks_source.username" => stack.custom_cookbooks_source.username
          }

          resources["aws_opsworks_stack.#{stack.name}"] = {
            "type" => "aws_opsworks_stack",
            "primary" => {
              "id" => stack.stack_id,
              "attributes" => attributes,
              "meta" => {
                "schema_version" => "1"
              }
            }
          }

          stack_layers(stack.stack_id).each do |layer|
            attributes = {
              "auto_assign_elastic_ips"       => layer.auto_assign_elastic_ips.to_s,
              "auto_assign_public_ips"        => layer.auto_assign_public_ips.to_s,
              "auto_healing"                  => layer.enable_auto_healing.to_s,
              "custom_instance_profile_arn"   => layer.custom_instance_profile_arn,
              "custom_security_group_ids"     => layer.custom_security_group_ids.join(","),
              "drain_elb_on_shutdown"         => layer.lifecycle_event_configuration.shutdown.delay_until_elb_connections_drained.to_s,
              "install_updates_on_boot"       => layer.install_updates_on_boot.to_s,
              "instance_shutdown_timeout"     => layer.lifecycle_event_configuration.shutdown.execution_timeout.to_s,
              "name"                          => layer.name,
              "short_name"                    => layer.shortname,
              "stack_id"                      => layer.stack_id,
              "use_ebs_optimized_instances"   => layer.use_ebs_optimized_instances.to_s,
            }

            attributes["custom_security_group_ids.#"] = layer.custom_security_group_ids.count.to_s
            layer.custom_security_group_ids.each do |sg|
              attributes["custom_security_group_ids.#{Zlib.crc32(sg)}"] = sg
            end

            attributes["system_packages.#"] = layer.packages.count.to_s
            layer.packages.each do |package|
              attributes["system_packages.#{Zlib.crc32(package)}"] = package
            end

            attributes["custom_setup_recipes.#"] = layer.custom_recipes.setup.count.to_s
            layer.custom_recipes.setup.each_with_index do |recipe, index|
              attributes["custom_setup_recipes.#{index}"] = recipe
            end

            attributes["custom_configure_recipes.#"] = layer.custom_recipes.configure.count.to_s
            layer.custom_recipes.configure.each_with_index do |recipe, index|
              attributes["custom_configure_recipes.#{index}"] = recipe
            end

            attributes["custom_deploy_recipes.#"] = layer.custom_recipes.deploy.count.to_s
            layer.custom_recipes.deploy.each_with_index do |recipe, index|
              attributes["custom_deploy_recipes.#{index}"] = recipe
            end

            attributes["custom_undeploy_recipes.#"] = layer.custom_recipes.undeploy.count.to_s
            layer.custom_recipes.undeploy.each_with_index do |recipe, index|
              attributes["custom_undeploy_recipes.#{index}"] = recipe
            end

            attributes["custom_shutdown_recipes.#"] = layer.custom_recipes.shutdown.count.to_s
            layer.custom_recipes.shutdown.each_with_index do |recipe, index|
              attributes["custom_shutdown_recipes.#{index}"] = recipe
            end

            attributes["ebs_volume.#"] = layer.volume_configurations.count.to_s
            layer.volume_configurations.each do |volume|
              index = Zlib.crc32(volume.mount_point)
              attributes["ebs_volume.#{index}.mount_point"] = volume.mount_point
              attributes["ebs_volume.#{index}.size"] = volume.size.to_s
              attributes["ebs_volume.#{index}.number_of_disks"] = volume.number_of_disks.to_s
              attributes["ebs_volume.#{index}.raid_level"] = volume.raid_level.to_s
              attributes["ebs_volume.#{index}.type"] = volume.volume_type
              attributes["ebs_volume.#{index}.iops"] = volume.iops.to_s
            end

            resources["aws_opsworks_custom_layer.#{stack.name}_#{layer.name}"] = {
              "type" => "aws_opsworks_custom_layer",
              "primary" => {
                "id" => layer.layer_id,
                "attributes" => attributes,
                "meta" => {
                  "schema_version" => "1"
                }
              }
            }
          end

          resources
        end
      end

      private

      def stacks
        @client.describe_stacks.stacks
      end

      def stack_layers(stack_id)
        @client.describe_layers({stack_id: stack_id}).layers
      end
    end
  end
end

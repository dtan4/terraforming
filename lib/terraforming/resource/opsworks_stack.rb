module Terraforming
  module Resource
    class OpsWorksStack
      include Terraforming::Util

      def self.tf(client: Aws::OpsWorks::Client.new(region: 'us-east-1'))
        self.new(client).tf
      end

      def self.tfstate(client: Aws::OpsWorks::Client.new(region: 'us-east-1'))
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/opsworks_stack")
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

          resources["aws_opsworks_stack.#{module_name_of(stack)}"] = {
            "type" => "aws_opsworks_stack",
            "primary" => {
              "id" => stack.stack_id,
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

      def stacks
        @client.describe_stacks.map(&:stacks).flatten
      end

      def module_name_of(stack)
        normalize_module_name(stack.name)
      end

    end
  end
end

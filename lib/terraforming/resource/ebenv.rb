module Terraforming
  module Resource
    class EBEnv
      include Terraforming::Util

      def self.tf(client: Aws::ElasticBeanstalk::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::ElasticBeanstalk::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/ebenv")
      end

      def tfstate
        environments.inject({}) do |resources, environment|
          settings = settings_of(environment)
          attributes = {
            "name" => environment.environment_name,
            "description" => environment.description ? environment.description : "",
            "application" => environment.application_name,
            "cname_prefix " => environment.cname,
            "tier" => environment.tier.name,
            "solution_stack_name" => environment.solution_stack_name,
            #{}"template_name" => environment.template_name,
            "settings.#" => settings.length.to_s
            #{}"tag.#" => environment.tags.length.to_s
            #no tags available with this call or any other at time of writing
          }

          settings.each do |setting|
            hashcode = setting_hashcode_of(setting)
            attributes.merge!({
              "setting.#{hashcode}.namespace" => setting.namespace,
              "setting.#{hashcode}.name" => setting.option_name,
              "setting.#{hashcode}.value" => setting.value ? setting.value : "",
              "setting.#{hashcode}.resource" => setting.resource_name ? setting.resource_name : ""
            })
          end

          resources["aws_elastic_beanstalk_application.#{module_name_of(environment)}"] = {
            "type" => "aws_elastic_beanstalk_application",
            "primary" => {
              "id" => environment.environment_name,
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

      def environments
        @client.describe_environments.map(&:environments).flatten
      end

      def module_name_of(environment)
        normalize_module_name(environment.environment_name)
      end

      def settings_of(environment)
        @client.describe_configuration_settings(application_name: environment.application_name, environment_name: environment.environment_name).configuration_settings.map(&:option_settings).flatten
      end

      def setting_hashcode_of(setting)
        Zlib.crc32("#{setting.namespace}-#{setting.option_name}-#{setting.resource}")
      end

    end
  end
end

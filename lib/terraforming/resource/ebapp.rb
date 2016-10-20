module Terraforming
  module Resource
    class EBApp
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
        apply_template(@client, "tf/ebapp")
      end

      def tfstate
        applications.inject({}) do |resources, application|
          attributes = {
            "name" => application.application_name,
            "description" => application.description ? application.description : ""
          }

          resources["aws_elastic_beanstalk_application.#{module_name_of(application)}"] = {
            "type" => "aws_elastic_beanstalk_application",
            "primary" => {
              "id" => application.application_name,
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

      def applications
        @client.describe_applications.map(&:applications).flatten
      end

      def module_name_of(application)
        normalize_module_name(application.application_name)
      end
    end
  end
end

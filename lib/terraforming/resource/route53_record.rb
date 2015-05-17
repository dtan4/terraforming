module Terraforming
  module Resource
    class Route53Record
      include Terraforming::Util

      def self.tf(client = Aws::Route53::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client = Aws::Route53::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/route53_record")
      end

      def tfstate
        resources = hosted_zones.inject({}) do |result, hosted_zone|
          zone_id = zone_id_of(hosted_zone)

          attributes = {
            "id"=> zone_id,
            "name"=> name_of(hosted_zone),
            "name_servers.#" => name_servers_of(hosted_zone).length.to_s,
            "tags.#" => tags_of(hosted_zone).length.to_s,
            "zone_id" => zone_id,
          }
          result["aws_route53_zone.#{module_name_of(hosted_zone)}"] = {
            "type" => "aws_route53_zone",
            "primary" => {
              "id" => zone_id,
              "attributes" => attributes,
            }
          }

          result
        end

        generate_tfstate(resources)
      end

      private

      def hosted_zones
        @client.list_hosted_zones.hosted_zones
      end

      def record_sets_of(hosted_zone)
        @client.list_resource_record_sets(hosted_zone_id: zone_id_of(hosted_zone)).resource_record_sets
      end

      def records
        hosted_zones.map { |hosted_zone| record_sets_of(hosted_zone) }.flatten
      end

      # TODO(dtan4): change method name...
      def name_of(dns_name)
        dns_name.gsub(/\.\z/, "")
      end

      def module_name_of(record)
        normalize_module_name(name_of(record.name))
      end

      def zone_id_of(hosted_zone)
        hosted_zone.id.gsub(/\A\/hostedzone\//, "")
      end
    end
  end
end

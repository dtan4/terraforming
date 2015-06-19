module Terraforming
  module Resource
    class Route53Zone
      include Terraforming::Util

      def self.tf(client: Aws::Route53::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::Route53::Client.new, tfstate_base: nil)
        self.new(client).tfstate(tfstate_base)
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/route53_zone")
      end

      def tfstate(tfstate_base)
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

        generate_tfstate(resources, tfstate_base)
      end

      private

      def hosted_zones
        @client.list_hosted_zones.hosted_zones
      end

      def tags_of(hosted_zone)
        @client.list_tags_for_resource(resource_type: "hostedzone", resource_id: zone_id_of(hosted_zone)).resource_tag_set.tags
      end

      def name_of(hosted_zone)
        hosted_zone.name.gsub(/\.\z/, "")
      end

      def name_servers_of(hosted_zone)
        @client.get_hosted_zone(id: hosted_zone.id).delegation_set.name_servers
      end

      def module_name_of(hosted_zone)
        normalize_module_name(name_of(hosted_zone))
      end

      def zone_id_of(hosted_zone)
        hosted_zone.id.gsub(/\A\/hostedzone\//, "")
      end
    end
  end
end

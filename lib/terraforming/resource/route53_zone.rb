module Terraforming
  module Resource
    class Route53Zone
      include Terraforming::Util

      def self.tf(client: Aws::Route53::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::Route53::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/route53_zone")
      end

      def tfstate
        hosted_zones.inject({}) do |resources, hosted_zone|
          zone_id = zone_id_of(hosted_zone)
          vpc = vpc_of(hosted_zone)

          attributes = {
            "comment" => comment_of(hosted_zone),
            "id" => zone_id,
            "name" => name_of(hosted_zone),
            "name_servers.#" => name_servers_of(hosted_zone).length.to_s,
            "tags.#" => tags_of(hosted_zone).length.to_s,
            "vpc_id" => vpc ? vpc.vpc_id : "",
            "vpc_region" => vpc ? vpc.vpc_region : "",
            "zone_id" => zone_id,
          }
          resources["aws_route53_zone.#{module_name_of(hosted_zone)}"] = {
            "type" => "aws_route53_zone",
            "primary" => {
              "id" => zone_id,
              "attributes" => attributes,
            }
          }

          resources
        end
      end

      private

      def hosted_zones
        @client.list_hosted_zones.map(&:hosted_zones).flatten.map { |hosted_zone| @client.get_hosted_zone(id: hosted_zone.id) }
      end

      def tags_of(hosted_zone)
        @client.list_tags_for_resource(resource_type: "hostedzone", resource_id: zone_id_of(hosted_zone)).resource_tag_set.tags
      end

      def comment_of(hosted_zone)
        hosted_zone.hosted_zone.config.comment
      end

      def name_of(hosted_zone)
        hosted_zone.hosted_zone.name.gsub(/\.\z/, "")
      end

      def name_servers_of(hosted_zone)
        delegation_set = hosted_zone.delegation_set
        delegation_set ? delegation_set.name_servers : []
      end

      def module_name_of(hosted_zone)
        normalize_module_name(name_of(hosted_zone)) << "-#{private_hosted_zone?(hosted_zone) ? 'private' : 'public'}"
      end

      def private_hosted_zone?(hosted_zone)
        hosted_zone.hosted_zone.config.private_zone
      end

      def vpc_of(hosted_zone)
        hosted_zone.vp_cs[0]
      end

      def zone_id_of(hosted_zone)
        hosted_zone.hosted_zone.id.gsub(%r{\A/hostedzone/}, "")
      end
    end
  end
end

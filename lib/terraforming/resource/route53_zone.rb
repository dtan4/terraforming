module Terraforming
  module Resource
    class Route53Zone
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
        apply_template(@client, "tf/route53_zone")
      end

      def tfstate

      end

      private

      def hosted_zones
        @client.list_hosted_zones.hosted_zones
      end

      def tags_of(hosted_zone)
        @client.list_tags_for_resource(resource_type: "hostedzone", resource_id: "hoge").resource_tag_set.tags
      end

      def name_of(hosted_zone)
        hosted_zone.name.gsub(/\.\z/, "")
      end

      def name_servers_of(hosted_zone)
        @client.get_hosted_zone(id: hosted_zone.id)
      end

      def module_name_of(hosted_zone)
        normalize_module_name(name_of(hosted_zone))
      end
    end
  end
end

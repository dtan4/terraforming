module Terraforming
  module Resource
    class Route53Record
      include Terraforming::Util

      def self.tf(match, client: Aws::Route53::Client.new)
        self.new(client, match).tf
      end

      def self.tfstate(match, client: Aws::Route53::Client.new)
        self.new(client, match).tfstate
      end

      def initialize(client, match)
        @client = client
        @match_regex = Regexp.new(match) if match
      end

      def tf
        apply_template(@client, "tf/route53_record")
      end

      def tfstate
        records.inject({}) do |resources, r|
          record, zone_id = r[:record], r[:zone_id]
          record_id = record_id_of(record, zone_id)

          attributes = {
            "id" => record_id,
            "name" => name_of(record.name.gsub(/\\052/, '*')),
            "type" => record.type,
            "zone_id" => zone_id,
          }

          attributes["alias.#"] = "1" if record.alias_target
          attributes["records.#"] = record.resource_records.length.to_s unless record.resource_records.empty?
          attributes["ttl"] = record.ttl.to_s if record.ttl
          attributes["weight"] = record.weight ? record.weight.to_s : "-1"
          attributes["set_identifier"] = record.set_identifier if record.set_identifier

          resources["aws_route53_record.#{module_name_of(record)}"] = {
            "type" => "aws_route53_record",
            "primary" => {
              "id" => record_id,
              "attributes" => attributes,
            }
          }

          resources
        end
      end

      private

      def hosted_zones
        @client.list_hosted_zones.map(&:hosted_zones).flatten
      end

      def record_id_of(record, zone_id)
        "#{zone_id}_#{name_of(record.name.gsub(/\\052/, '*'))}_#{record.type}"
      end

      def record_sets_of(hosted_zone)
        @client.list_resource_record_sets(hosted_zone_id: zone_id_of(hosted_zone)).map do |response|
          response.data.resource_record_sets
        end.flatten.select do |resource|
          @match_regex ? module_name_of(resource) =~ @match_regex : 1
        end
      end

      def records
        hosted_zones.map do |hosted_zone|
          record_sets_of(hosted_zone).map { |record| { record: record, zone_id: zone_id_of(hosted_zone) } }
        end.flatten
      end

      # TODO(dtan4): change method name...
      def name_of(dns_name)
        dns_name.gsub(/\.\z/, "")
      end

      def module_name_of(record)
        normalize_module_name(name_of(record.name) + "-" + record.type)
      end

      def zone_id_of(hosted_zone)
        hosted_zone.id.gsub(%r{\A/hostedzone/}, "")
      end
    end
  end
end

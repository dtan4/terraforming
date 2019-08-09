module Terraforming
  module Resource
    class Route53Record
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
        apply_template(@client, "tf/route53_record")
      end

      def tfstate
        records.inject({}) do |resources, r|
          record, zone_id = r[:record], r[:zone_id]
          counter = r[:counter]
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
          attributes["region"] = record.region if record.region

          if record.geo_location
            attributes["continent"] = record.geo_location.continent_code if record.geo_location.continent_code
            attributes["country"] = record.geo_location.country_code if record.geo_location.country_code
            attributes["subdivision"] = record.geo_location.subdivision_code if record.geo_location.subdivision_code
          end

          if record.failover
            attributes["failover_routing_policy.#"] = "1"
            attributes["failover_routing_policy.0.type"] = record.failover
          end

          attributes["set_identifier"] = record.set_identifier if record.set_identifier
          attributes["health_check_id"] = record.health_check_id if record.health_check_id

          resources["aws_route53_record.#{module_name_of(record, counter)}"] = {
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
        end.flatten
      end

      def records
        to_return = hosted_zones.map do |hosted_zone|
          record_sets_of(hosted_zone).map { |record| { record: record, zone_id: zone_id_of(hosted_zone) } }
        end.flatten
        count = {}
        dups = to_return.group_by { |record| module_name_of(record[:record], nil) }.select { |_, v| v.size > 1 }.map(&:first)
        to_return.each do |r|
          module_name = module_name_of(r[:record], nil)
          next unless dups.include?(module_name)
          count[module_name] = count[module_name] ? count[module_name] + 1 : 0
          r[:counter] = count[module_name]
        end
        to_return
      end

      # TODO(dtan4): change method name...
      def name_of(dns_name)
        dns_name.gsub(/\.\z/, "")
      end

      def module_name_of(record, counter)
        normalize_module_name(name_of(record.name.gsub(/\\052/, 'wildcard')) + "-" + record.type + (!counter.nil? ? "-" + counter.to_s : ""))
      end

      def zone_id_of(hosted_zone)
        hosted_zone.id.gsub(%r{\A/hostedzone/}, "")
      end
    end
  end
end

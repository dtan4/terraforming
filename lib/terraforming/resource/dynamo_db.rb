module Terraforming
  module Resource
    class DynamoDB
      include Terraforming::Util
      def self.tf(client: Aws::DynamoDB::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::DynamoDB::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/dynamo_db")
      end

      def tfstate
        tables.inject({}) do |resources, dynamo_db_table|
          attributes = {
            "arn"                       => dynamo_db_table["table_arn"],
            "id"                        => dynamo_db_table["table_name"],
            "name"                      => dynamo_db_table["table_name"],
            "read_capacity"             => dynamo_db_table["provisioned_throughput"]["read_capacity_units"].to_s,
            "stream_arn"                => dynamo_db_table["latest_stream_arn"].to_s,
            "stream_label"              => dynamo_db_table["latest_stream_label"].to_s,
            "write_capacity"            => dynamo_db_table["provisioned_throughput"]["write_capacity_units"].to_s
          }

          attributes.merge!(attribute_definitions(dynamo_db_table))
          attributes.merge!(global_indexes(dynamo_db_table))
          attributes.merge!(local_indexes(dynamo_db_table))
          attributes.merge!(key_schema(dynamo_db_table))
          attributes.merge!(point_in_time_summary(dynamo_db_table))
          attributes.merge!(sse_description(dynamo_db_table))
          attributes.merge!(stream_specification(dynamo_db_table))
          attributes.merge!(tags_of(dynamo_db_table))
          attributes.merge!(ttl_of(dynamo_db_table))

          resources["aws_dynamodb_table.#{module_name_of(dynamo_db_table)}"] = {
            "type"    => "aws_dynamodb_table",
            "primary" => {
              "id" => dynamo_db_table.table_name,
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

      def tables
        tables = []
        dynamo_db_tables.each do |table|
          attributes = @client.describe_table({
            table_name: table
          }).table
          tables << attributes
        end
        return tables
      end

      def attribute_definitions(dynamo_db_table)
        attributes = { "attribute.#" => dynamo_db_table["attribute_definitions"].length.to_s}
        dynamo_db_table["attribute_definitions"].each do |attr_defn|
          attributes.merge!(attributes_definitions_of(attr_defn))
        end
        attributes
      end

      def attributes_definitions_of(attr_defn)
        hashcode = attribute_hashcode(attr_defn)
        attributes = {
          "attribute.#{hashcode}.name" => attr_defn.attribute_name,
          "attribute.#{hashcode}.type" => attr_defn.attribute_type,
        }
        attributes
      end

      def attribute_hashcode(attr_defn)
        hashcode = Zlib.crc32(attr_defn.attribute_name+"-")
      end

      def global_indexes(dynamo_db_table)
        attributes = {}
        if dynamo_db_table["global_secondary_indexes"]
          attributes = { "global_secondary_index.#"  => dynamo_db_table["global_secondary_indexes"].length.to_s}
          dynamo_db_table["global_secondary_indexes"].each do |global_sec_index|
            attributes.merge!(global_secondary_indexes_of(global_sec_index))
          end
        end
        return attributes
      end


      def global_secondary_indexes_of(global_sec_index)
        attributes = global_indexes_of(global_sec_index).merge!(global_index_non_key_attributes(global_sec_index))
      end

      def global_indexes_of(global_sec_index)
        hashcode = global_index_hashcode(global_sec_index)
        attributes = {
          "global_secondary_index.#{hashcode}.hash_key" => find_key(global_sec_index,"HASH"),
          "global_secondary_index.#{hashcode}.name" => global_sec_index.index_name,
          "global_secondary_index.#{hashcode}.projection_type" => global_sec_index.projection.projection_type,
          "global_secondary_index.#{hashcode}.range_key" => find_key(global_sec_index,"RANGE"),
          "global_secondary_index.#{hashcode}.read_capacity" => global_sec_index.provisioned_throughput.read_capacity_units.to_s ,
          "global_secondary_index.#{hashcode}.write_capacity" => global_sec_index.provisioned_throughput.write_capacity_units.to_s,
        }
        attributes
      end

      def find_key(index,key_type)
        index["key_schema"].each do |schema|
          if schema.key_type == key_type
            return schema.attribute_name
          else
            return ""
          end
        end
      end

      def global_index_non_key_attributes(global_sec_index)
        attributes = {}
        if !global_sec_index["projection"]["non_key_attributes"].nil?
          hashcode = global_index_hashcode(global_sec_index)
          attributes = {"global_secondary_index.#{hashcode}.non_key_attributes.#" => global_sec_index["projection"]["non_key_attributes"].length.to_s}
          (0..global_sec_index["projection"]["non_key_attributes"].length.to_i-1).each do |index|
            attributes.merge!({"global_secondary_index.#{hashcode}.non_key_attributes.#{index}" => global_sec_index["projection"]["non_key_attributes"][index]})
          end
        end
        attributes
      end


      def global_index_hashcode(global_sec_index)
        Zlib.crc32(global_sec_index["index_name"]+"-")
      end

      def local_indexes(dynamo_db_table)
        attributes = {}
        if dynamo_db_table["local_secondary_indexes"]
          attributes = {"local_secondary_index.#"  => dynamo_db_table["local_secondary_indexes"].length.to_s}
          dynamo_db_table["local_secondary_indexes"].each do |local_sec_index|
            attributes.merge!(local_secondary_indexes_of(local_sec_index))
          end
        end
        return attributes
      end

      def local_secondary_indexes_of(local_sec_index)
        attributes = {}
        hashcode = local_index_hashcode(local_sec_index)
        attributes.merge!("local_secondary_index.#{hashcode}.range_key" => find_key(local_sec_index,"RANGE")) if !find_key(local_sec_index,"RANGE").empty?
        attributes.merge!({
          "local_secondary_index.#{hashcode}.name" => local_sec_index.index_name,
          "local_secondary_index.#{hashcode}.projection_type" => local_sec_index.projection.projection_type,
        })
        attributes.merge!(local_index_non_key_attributes(local_sec_index))
        attributes
      end

      def local_index_non_key_attributes(local_sec_index)
        attributes = {}
        if !local_sec_index["projection"]["non_key_attributes"].nil?
          hashcode = local_index_hashcode(local_sec_index)
          attributes = {"local_secondary_index.#{hashcode}.non_key_attributes.#" => local_sec_index["projection"]["non_key_attributes"].length.to_s}
          (0..local_sec_index["projection"]["non_key_attributes"].length.to_i-1).each do |index|
            attributes.merge!({"local_secondary_index.#{hashcode}.non_key_attributes.#{index}" => local_sec_index["projection"]["non_key_attributes"][index]})
          end
        end
        attributes
      end

      def local_index_hashcode(local_index)
        Zlib.crc32(local_index["index_name"]+"-")
      end

      def key_schema(dynamo_db_table)
        attributes = {}
        if dynamo_db_table["key_schema"]
          attributes = {"key_schema.#"  => dynamo_db_table["key_schema"].length.to_s}
          if !find_key(dynamo_db_table,"HASH").empty? 
            attributes.merge!({"hash_key" => find_key(dynamo_db_table,"HASH")})
          end
        end
        attributes
      end

      def point_in_time_summary(dynamo_db_table)
        resp = @client.describe_continuous_backups({
          table_name: dynamo_db_table["table_name"]
        })
        if resp.continuous_backups_description.point_in_time_recovery_description.point_in_time_recovery_status == "ENABLED"
          attributes = {"point_in_time_recovery.#" => 1.to_s}
          attributes.merge!({"point_in_time_recovery.0.enabled" => true.to_s})
        else
          attributes = {"point_in_time_recovery.#" => 0.to_s}
        end
      end

      def sse_description(dynamo_db_table)
        attributes = {}
        if dynamo_db_table.sse_description
          if dynamo_db_table.sse_description.status == "ENABLED"
            attributes = {"server_side_encryption.#" => 1.to_s}
            attributes.merge!({"server_side_encryption.0.enabled" => true.to_s})
          end
        else
          attributes.merge!({"server_side_encryption.#" => 0.to_s})
        end
        attributes
      end

      def stream_specification(dynamo_db_table)
        attributes = {}
        if dynamo_db_table.stream_specification
          attributes = {"stream_view_type" => dynamo_db_table.stream_specification.stream_view_type} if dynamo_db_table.stream_specification.stream_enabled
        end
        attributes
      end

      def ttl_of(dynamo_db_table)
        attributes = {}
        ttl = ttl_values(dynamo_db_table)
        if !ttl.empty?
          hashcode = ttl_hashcode(ttl.first)
          attributes = {"ttl.#" => 1.to_s} 
          attributes["ttl.#{hashcode}.attribute_name"] = ttl.first
          attributes["ttl.#{hashcode}.enabled"] = true.to_s
        end
        return attributes
      end

      def ttl_hashcode(attribute)
        Zlib.crc32(attribute)
      end

      def tags_of(dynamo_db_table)
        attributes = {}
        tags = tags(dynamo_db_table)
        if !tags.empty?
          attributes = { "tags.%" => tags.length.to_s }
          tags.each do |tag|
            attributes["tags.#{tag.key}"] = tag.value
          end
        end
        attributes
      end

      def dynamo_db_tables
        a = @client.list_tables.map(&:table_names).flatten
      end

      def ttl_values(dynamo_db_table)
        ttl = @client.describe_time_to_live({
          table_name: dynamo_db_table.table_name
        }).time_to_live_description
        if ttl.time_to_live_status == "ENABLED"
          return [ttl.attribute_name]
        else 
          return []
        end
      end

      def tags(dynamo_db_table)
        resp = @client.list_tags_of_resource({resource_arn: dynamo_db_table.table_arn}).tags
      end

      def module_name_of(dynamo_db_table)
        normalize_module_name(dynamo_db_table['table_name'])
      end
    end
  end
end

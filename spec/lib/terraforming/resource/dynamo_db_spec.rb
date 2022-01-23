require "spec_helper"

module Terraforming
  module Resource
    describe DynamoDB do
      let(:client) do
        Aws::DynamoDB::Client.new(stub_responses: true)
      end

      let(:tables) do
       [
          "test-ddb","new-ddb"
        ]
      end

      let(:test_ddb_table) do
        {
          attribute_definitions: 
          [
            { attribute_name: "account_id", attribute_type: "N" },
            { attribute_name: "action_timestamp", attribute_type: "N" },
            { attribute_name: "type_parentid_timestamp", attribute_type: "S" },
            {attribute_name: "newky", attribute_type: "S"}, 
            {attribute_name: "newsortkey", attribute_type: "S"}, 
          ],
         table_name: "test-ddb",
         key_schema: [
          {attribute_name: "account_id", key_type: "HASH"}, 
          {attribute_name: "type_parentid_timestamp", key_type: "RANGE"}
         ],
         table_status: "ACTIVE",
         creation_date_time: Time.parse("2016-08-31 06:23:57 UTC"),
         provisioned_throughput:  { number_of_decreases_today: 0, read_capacity_units: 1, write_capacity_units: 1 },
         table_size_bytes: 0,
         item_count: 0,
         table_arn: "arn:aws:dynamodb:eu-central-1:123456789:table/test-ddb",
         local_secondary_indexes: [
            {
              index_name: "action_timestamp_index",
              key_schema: [
                {attribute_name: "account_id", key_type: "HASH"},
                {attribute_name: "action_timestamp", key_type: "RANGE"}
              ],
            projection: { projection_type: "INCLUDE", non_key_attributes: ["fghi", "jklm"] },
            index_size_bytes: 0,
            item_count: 0,
            index_arn: "arn:aws:dynamodb:eu-central-1:123456789:table/test-ddb/index/action_timestamp_index"}
          ],
        global_secondary_indexes: [
          {
            index_name: "newky-newsortkey-index", 
            key_schema: [
              {attribute_name: "newky", key_type: "HASH"}, 
              {attribute_name: "newsortkey", key_type: "RANGE"}
            ],
            projection: { projection_type: "INCLUDE", non_key_attributes: ["abcd", "efgh"] },
            index_status: "ACTIVE",
            provisioned_throughput:  { number_of_decreases_today: 0, read_capacity_units: 1, write_capacity_units: 1 },
            index_size_bytes: 0, 
            item_count: 0,
            index_arn: "arn:aws:dynamodb:eu-central-1:123456789:table/test-ddb/index/newky-newsortkey-index"}
          ],
        stream_specification: {stream_enabled: true, stream_view_type: "NEW_AND_OLD_IMAGES"},
        latest_stream_label: Time.parse("2016-08-31 06:23:57 UTC").to_s, 
        latest_stream_arn: "arn:aws:dynamodb:eu-central-1:123456789:table/test-ddb/stream/"+Time.parse("2016-08-31 06:23:57 UTC").to_s,
        sse_description: {
          status: "ENABLED" 
        }
      }
      end

      let(:new_ddb_table) do
        {
          attribute_definitions:[
            {:attribute_name=>"id", :attribute_type=>"S"},
            {:attribute_name=>"time", :attribute_type=>"N"}
          ], 
        table_name: "new-ddb",
        key_schema: [
          {:attribute_name=>"id", :key_type=>"HASH"},
          {:attribute_name=>"time", :key_type=>"RANGE"}
        ],
        table_status: "ACTIVE", 
        creation_date_time: Time.parse("2016-08-31 06:23:57 UTC"),
        provisioned_throughput: {number_of_decreases_today: 0, read_capacity_units: 5, write_capacity_units: 5}, 
        table_size_bytes: 12345, 
        item_count: 11222,
        :table_arn=>"arn:aws:dynamodb:eu-central-1:123456789:table/new-ddb",
        :table_id=>"new-ddb"
      }
      end

      let(:test_ddb_continuous_backups_description) do
        {
          continuous_backups_status: "ENABLED", 
          point_in_time_recovery_description: { 
            point_in_time_recovery_status: "ENABLED"
          }
        }
      end

      let(:new_ddb_continuous_backups_description) do
        {
          continuous_backups_status: "ENABLED", 
          point_in_time_recovery_description: { 
            point_in_time_recovery_status: "DISABLED"
          }
        }
      end

      let(:test_ddb_describe_time_to_live) do
        {:time_to_live_status=>"ENABLED", :attribute_name=>"1"}
      end

      let(:new_ddb_describe_time_to_live) do
        {:time_to_live_status=>"DISABLED"}
      end

      let(:test_ddb_tags) do
        [{:key=>"abcd", :value=>"efgh"}]
      end

      let(:new_ddb_tags) do
        []
      end

      before do
        client.stub_responses(:list_tables, table_names: tables)
        client.stub_responses(:describe_table, [
          {table: test_ddb_table},
          {table: new_ddb_table}
        ])
        client.stub_responses(:describe_continuous_backups,[
          {continuous_backups_description: test_ddb_continuous_backups_description},
          {continuous_backups_description: new_ddb_continuous_backups_description}
        ])
        client.stub_responses(:describe_time_to_live, [
          {time_to_live_description: test_ddb_describe_time_to_live},
          {time_to_live_description: new_ddb_describe_time_to_live}
        ])
        client.stub_responses(:list_tags_of_resource, [
          {tags: test_ddb_tags},
          {tags: new_ddb_tags}
        ])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_dynamodb_table" "test-ddb" {
    name = "test-ddb"
    read_capacity = 1
    write_capacity = 1
    hash_key = "account_id"
    range_key = "type_parentid_timestamp"

    attribute {
        name = "account_id"
        type = "N"
    }
    attribute {
        name = "action_timestamp"
        type = "N"
    }
    attribute {
        name = "type_parentid_timestamp"
        type = "S"
    }
    attribute {
        name = "newky"
        type = "S"
    }
    attribute {
        name = "newsortkey"
        type = "S"
    }
    ttl {
        attribute_name = "1"
        enabled = true
    }
    global_secondary_index {
        name = "newky-newsortkey-index"
        hash_key = "newky"
        range_key = "newsortkey"
        read_capacity = 1
        write_capacity = 1
        projection_type = "INCLUDE"
        non_key_attributes = ["abcd", "efgh"]
    }
    local_secondary_index {
        name = "action_timestamp_index"
        range_key = "action_timestamp"
        projection_type = "INCLUDE"
        non_key_attributes = ["fghi", "jklm"]
    }
    tags = {
        abcd = "efgh"
    }
    stream_enabled = true
    stream_view_type = "NEW_AND_OLD_IMAGES"
    server_side_encryption {
        enabled = true
    }
}
resource "aws_dynamodb_table" "new-ddb" {
    name = "new-ddb"
    read_capacity = 5
    write_capacity = 5
    hash_key = "id"
    range_key = "time"

    attribute {
        name = "id"
        type = "S"
    }
    attribute {
        name = "time"
        type = "N"
    }
}
EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_dynamodb_table.test-ddb"=>
            {
             "type"=>"aws_dynamodb_table",
             "primary"=>
             {
              "id"=>"test-ddb",
              "attributes"=>
              {
              "arn"=>"arn:aws:dynamodb:eu-central-1:123456789:table/test-ddb",
              "id"=>"test-ddb",
              "name"=>"test-ddb",
              "read_capacity"=>"1",
              "stream_arn"=>"arn:aws:dynamodb:eu-central-1:123456789:table/test-ddb/stream/2016-08-31 06:23:57 UTC",
              "stream_label"=>"2016-08-31 06:23:57 UTC",
              "write_capacity"=>"1",
              "attribute.#"=>"5",
              "attribute.3170009653.name"=>"account_id",
              "attribute.3170009653.type"=>"N",
              "attribute.901452415.name"=>"action_timestamp",
              "attribute.901452415.type"=>"N",
              "attribute.2131915850.name"=>"type_parentid_timestamp",
              "attribute.2131915850.type"=>"S",
              "attribute.3685094810.name"=>"newky",
              "attribute.3685094810.type"=>"S",
              "attribute.3333016131.name"=>"newsortkey",
              "attribute.3333016131.type"=>"S",
              "global_secondary_index.#"=>"1",
              "global_secondary_index.1661317069.hash_key"=>"newky",
              "global_secondary_index.1661317069.name"=>"newky-newsortkey-index",
              "global_secondary_index.1661317069.projection_type"=>"INCLUDE",
              "global_secondary_index.1661317069.range_key"=>"",
              "global_secondary_index.1661317069.read_capacity"=>"1",
              "global_secondary_index.1661317069.write_capacity"=>"1",
              "global_secondary_index.1661317069.non_key_attributes.#"=>"2",
              "global_secondary_index.1661317069.non_key_attributes.0"=>"abcd",
              "global_secondary_index.1661317069.non_key_attributes.1"=>"efgh",
              "local_secondary_index.#"=>"1",
              "local_secondary_index.2469045277.name"=>"action_timestamp_index",
              "local_secondary_index.2469045277.projection_type"=>"INCLUDE",
              "local_secondary_index.2469045277.non_key_attributes.#"=>"2",
              "local_secondary_index.2469045277.non_key_attributes.0"=>"fghi",
              "local_secondary_index.2469045277.non_key_attributes.1"=>"jklm",
              "key_schema.#"=>"2",
              "hash_key"=>"account_id",
              "point_in_time_recovery.#"=>"1",
              "point_in_time_recovery.0.enabled"=>"true",
              "server_side_encryption.#"=>"1",
              "server_side_encryption.0.enabled"=>"true",
              "stream_view_type"=>"NEW_AND_OLD_IMAGES",
              "tags.%"=>"1",
              "tags.abcd"=>"efgh",
              "ttl.#"=>"1",
              "ttl.2212294583.attribute_name"=>"1",
              "ttl.2212294583.enabled"=>"true"
            },
             "meta"=>{"schema_version"=>"1"}
           }
         }, 
             "aws_dynamodb_table.new-ddb"=>
             {
              "type"=>"aws_dynamodb_table",
              "primary"=>
              {
                "id"=>"new-ddb",
              "attributes"=>
              {
                "arn"=>"arn:aws:dynamodb:eu-central-1:123456789:table/new-ddb",
                "id"=>"new-ddb",
                "name"=>"new-ddb",
                "read_capacity"=>"5",
                "stream_arn"=>"",
                "stream_label"=>"",
                "write_capacity"=>"5",
                "attribute.#"=>"2",
                "attribute.4228504427.name"=>"id",
                "attribute.4228504427.type"=>"S",
                "attribute.2432995967.name"=>"time",
                "attribute.2432995967.type"=>"N",
                "key_schema.#"=>"2", "hash_key"=>"id",
                "point_in_time_recovery.#"=>"0",
                "server_side_encryption.#"=>"0"},
                "meta"=>{"schema_version"=>"1"}
              }
            }
          })
       end
      end
    end
  end
end

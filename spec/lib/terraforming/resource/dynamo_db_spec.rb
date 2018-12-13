require "spec_helper"

module Terraforming
  module Resource
    describe DynamoDb do
      let(:client) do
        Aws::DynamoDB::Client.new(stub_responses: true)
      end

      let(:tables) do
       [
          "test-ddb"
        ]
      end

      let(:test_dynamodb_table) do
        {
          attribute_definitions: 
          [
            { attribute_name: "account_id", attribute_type: "N" },
            { attribute_name: "action_timestamp", attribute_type: "N" },
            { attribute_name: "type_parentid_timestamp", attribute_type: "S" }
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
            projection: { projection_type: "ALL" },
            index_size_bytes: 0,
            item_count: 0,
            index_arn: "arn:aws:dynamodb:eu-central-1:123456789:table/test-ddb/index/action_timestamp_index"}
          ]
      }
      end

      let(:test_ddb_continuous_backups_description) do
        {
         continuous_backups_status: "ENABLED",
         point_in_time_recovery_description: {point_in_time_recovery_status: "DISABLED"}
        }
      end

      let(:test_ddb_describe_time_to_live) do
        {time_to_live_status: "DISABLED"}
      end

      let(:test_ddb_tags) do
        []
      end

      before do
        client.stub_responses(:list_tables, table_names: tables)
        client.stub_responses(:describe_table, table: test_dynamodb_table)
        client.stub_responses(:describe_continuous_backups, continuous_backups_description: test_ddb_continuous_backups_description)
        client.stub_responses(:describe_time_to_live, time_to_live_description: test_ddb_describe_time_to_live )
        client.stub_responses(:list_tags_of_resource, tags: test_ddb_tags)
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

    local_secondary_index {
        name = "action_timestamp_index"
        range_key = "action_timestamp"
        projection_type = "ALL"
    }
}
        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
          "aws_dynamodb_table.test-ddb" =>  {
            "type" =>  "aws_dynamodb_table",
            "primary" =>  {
              "id" =>  "test-ddb",
              "attributes" =>  {
                "arn" =>  "arn:aws:dynamodb:eu-central-1:123456789:table/test-ddb",
                "id" =>  "test-ddb",
                "name" =>  "test-ddb",
                "read_capacity" =>  "1",
                "stream_arn" =>  "",
                "stream_label" =>  "",
                "write_capacity" =>  "1",
                "attribute.#" =>  "3",
                "attribute.3170009653.name" =>  "account_id",
                "attribute.3170009653.type" =>  "N",
                "attribute.901452415.name" =>  "action_timestamp",
                "attribute.901452415.type" =>  "N",
                "attribute.2131915850.name" =>  "type_parentid_timestamp",
                "attribute.2131915850.type" =>  "S",
                "local_secondary_index.#" =>  "1",
                "local_secondary_index.2469045277.name" =>  "action_timestamp_index",
                "local_secondary_index.2469045277.projection_type" =>  "ALL",
                "key_schema.#" =>  "2",
                "hash_key" =>  "account_id",
                "point_in_time_recovery.#" =>  "0"
            },
            "meta" =>  {
              "schema_version" =>  "1"
            }
          }
        }
    })
    end
        end
      end
    end
end

require "spec_helper"

module Terraforming
  module Resource
    describe DBParameterGroup do
      let(:client) do
        Aws::RDS::Client.new(stub_responses: true)
      end

      let(:db_parameter_groups) do
        [
          {
            db_parameter_group_name: "default.mysql5.6",
            db_parameter_group_family: "mysql5.6",
            description: "Default parameter group for mysql5.6"
          },
          {
            db_parameter_group_name: "default.postgres9.4",
            db_parameter_group_family: "postgres9.4",
            description: "Default parameter group for postgres9.4"
          }
        ]
      end

      let(:mysql_parameters) do
        [
          {
            parameter_name: "application_name",
            parameter_value: nil,
            description: "Name of the application",
            source: "engine-default",
            apply_type: "dynamic",
            data_type: "string",
            allowed_values: nil,
            is_modifiable: true,
            minimum_engine_version: nil,
            apply_method: nil
          },
          {
            parameter_name: "archive_command",
            parameter_value: "/path/to/archive %p",
            description: "Command to archive database",
            source: "system",
            apply_type: "dynamic",
            data_type: "string",
            allowed_values: nil,
            is_modifiable: false,
            minimum_engine_version: nil,
            apply_method: nil
          }
        ]
      end

      let(:pg_parameters) do
        [
          {
            parameter_name: "archive_timeout",
            parameter_value: "300",
            description: "Timeout seconds for archiving",
            source: "system",
            apply_type: "dynamic",
            data_type: "integer",
            allowed_values: "0-214748364",
            is_modifiable: false,
            minimum_engine_version: nil,
            apply_method: nil
          },
          {
            parameter_name: "array_nulls",
            parameter_value: nil,
            description: "Enable input of NULL elements",
            source: "engine-default",
            apply_type: "dynamic",
            data_type: "boolean",
            allowed_values: "0,1",
            is_modifiable: false,
            minimum_engine_version: nil,
            apply_method: nil
          }
        ]
      end

      before do
        client.stub_responses(:describe_db_parameter_groups, db_parameter_groups: db_parameter_groups)
        client.stub_responses(:describe_db_parameters, [{ parameters: mysql_parameters }, { parameters: pg_parameters }])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_db_parameter_group" "default-mysql5-6" {
    name        = "default.mysql5.6"
    family      = "mysql5.6"
    description = "Default parameter group for mysql5.6"

    parameter {
        name         = "application_name"
        value        = ""
        apply_method = "immediate"
    }

    parameter {
        name         = "archive_command"
        value        = "/path/to/archive %p"
        apply_method = "immediate"
    }

}

resource "aws_db_parameter_group" "default-postgres9-4" {
    name        = "default.postgres9.4"
    family      = "postgres9.4"
    description = "Default parameter group for postgres9.4"

    parameter {
        name         = "archive_timeout"
        value        = "300"
        apply_method = "immediate"
    }

    parameter {
        name         = "array_nulls"
        value        = ""
        apply_method = "immediate"
    }

}

        EOS
        end

        describe ".tfstate" do
          context "without existing tfstate" do
            it "should generate tfstate" do
              expect(described_class.tfstate(client: client)).to eq JSON.pretty_generate({
                "version" => 1,
                "serial" => 1,
                "modules" => [
                  {
                    "path" => [
                      "root"
                    ],
                    "outputs" => {},
                    "resources" => {
                      "aws_db_parameter_group.default-mysql5-6" => {
                        "type" => "aws_db_parameter_group",
                        "primary" => {
                          "id" => "default.mysql5.6",
                          "attributes" => {
                            "description" => "Default parameter group for mysql5.6",
                            "family" => "mysql5.6",
                            "id" => "default.mysql5.6",
                            "name" => "default.mysql5.6",
                            "parameter.#" => "2",
                          }
                        }
                      },
                      "aws_db_parameter_group.default-postgres9-4" => {
                        "type" => "aws_db_parameter_group",
                        "primary" => {
                          "id" => "default.postgres9.4",
                          "attributes" => {
                            "description" => "Default parameter group for postgres9.4",
                            "family" => "postgres9.4",
                            "id" => "default.postgres9.4",
                            "name" => "default.postgres9.4",
                            "parameter.#" => "2",
                          }
                        }
                      }
                    }
                  }
                ]
              })
            end
          end

          context "with existing tfstate" do
            it "should generate tfstate and merge it to existing tfstate" do
              expect(described_class.tfstate(client: client, tfstate_base: tfstate_fixture)).to eq JSON.pretty_generate({
                "version" => 1,
                "serial" => 89,
                "remote" => {
                  "type" => "s3",
                  "config" => { "bucket" => "terraforming-tfstate", "key" => "tf" }
                },
                "modules" => [
                  {
                    "path" => ["root"],
                    "outputs" => {},
                    "resources" => {
                      "aws_elb.hogehoge" => {
                        "type" => "aws_elb",
                        "primary" => {
                          "id" => "hogehoge",
                          "attributes" => {
                            "availability_zones.#" => "2",
                            "connection_draining" => "true",
                            "connection_draining_timeout" => "300",
                            "cross_zone_load_balancing" => "true",
                            "dns_name" => "hoge-12345678.ap-northeast-1.elb.amazonaws.com",
                            "health_check.#" => "1",
                            "id" => "hogehoge",
                            "idle_timeout" => "60",
                            "instances.#" => "1",
                            "listener.#" => "1",
                            "name" => "hoge",
                            "security_groups.#" => "2",
                            "source_security_group" => "default",
                            "subnets.#" => "2"
                          }
                        }
                      },
                      "aws_db_parameter_group.default-mysql5-6" => {
                        "type" => "aws_db_parameter_group",
                        "primary" => {
                          "id" => "default.mysql5.6",
                          "attributes" => {
                            "description" => "Default parameter group for mysql5.6",
                            "family" => "mysql5.6",
                            "id" => "default.mysql5.6",
                            "name" => "default.mysql5.6",
                            "parameter.#" => "2",
                          }
                        }
                      },
                      "aws_db_parameter_group.default-postgres9-4" => {
                        "type" => "aws_db_parameter_group",
                        "primary" => {
                          "id" => "default.postgres9.4",
                          "attributes" => {
                            "description" => "Default parameter group for postgres9.4",
                            "family" => "postgres9.4",
                            "id" => "default.postgres9.4",
                            "name" => "default.postgres9.4",
                            "parameter.#" => "2",
                          }
                        }
                      }
                    }
                  }
                ]
              })
            end
          end
        end
      end
    end
  end
end

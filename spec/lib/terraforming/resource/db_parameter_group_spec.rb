require "spec_helper"

module Terraforming::Resource
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
          description: "Name of the application",
          data_type: "string",
          source: "engine-default",
          is_modifiable: true,
          parameter_name: "application_name",
          apply_type: "dynamic"
        },
        {
          description: "Command to archive database",
          data_type: "string",
          is_modifiable: false,
          source: "system",
          parameter_value: "/path/to/archive %p",
          parameter_name: "archive_command",
          apply_type: "dynamic"
        }
      ]
    end

    let(:pg_parameters) do
      [
        {
          description: "Timeout seconds for archiving",
          data_type: "integer",
          is_modifiable: false,
          allowed_values: "0-2147483647",
          source: "system",
          parameter_value: "300",
          parameter_name: "archive_timeout",
          apply_type: "dynamic"
        },
        {
          description: "Enable input of NULL elements",
          data_type: "boolean",
          is_modifiable: false,
          allowed_values: "0,1",
          source: "engine-default",
          parameter_name: "array_nulls",
          apply_type: "dynamic"
        }
      ]
    end

    before do
      client.stub_responses(:describe_db_parameter_groups, db_parameter_groups: db_parameter_groups)
      client.stub_responses(:describe_db_parameters, [{ parameters: mysql_parameters }, { parameters: pg_parameters }])
    end

    describe ".tf" do
      it "should generate tf" do
        expect(described_class.tf(client)).to eq <<-EOS
resource "aws_db_parameter_group" "default.mysql5.6" {
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

resource "aws_db_parameter_group" "default.postgres9.4" {
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
        value        = "0"
        apply_method = "immediate"
    }
}

        EOS
      end

      describe ".tfstate" do
        it "should raise NotImplementedError" do
          expect do
            described_class.tfstate(client)
          end.to raise_error NotImplementedError
        end
      end
    end
  end
end

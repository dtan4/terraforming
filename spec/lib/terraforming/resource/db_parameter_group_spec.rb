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

    before do
      client.stub_responses(:describe_db_parameter_groups, db_parameter_groups: db_parameter_groups)
    end

    describe ".tf" do
      it "should generate tf" do
        expect(described_class.tf(client)).to eq <<-EOS
resource "aws_db_parameter_group" "default.mysql5.6" {
    name        = "default.mysql5.6"
    family      = "mysql5.6"
    description = "Default parameter group for mysql5.6"
}

resource "aws_db_parameter_group" "default.postgres9.4" {
    name        = "default.postgres9.4"
    family      = "postgres9.4"
    description = "Default parameter group for postgres9.4"
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

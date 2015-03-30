require "spec_helper"

module Terraforming::Resource
  describe DBParameterGroup do
    describe ".tf" do
      let(:json) do
        JSON.parse(open(fixture_path("rds/describe-db-parameter-groups")).read)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(json)).to eq <<-EOS
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
      end
    end
  end
end

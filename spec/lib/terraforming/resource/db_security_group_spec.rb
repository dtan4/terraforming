require "spec_helper"

module Terraforming::Resource
  describe DBSecurityGroup do
    describe ".tf" do
      let(:json) do
        JSON.parse(open(fixture_path("rds/describe-db-security-groups")).read)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(json)).to eq <<-EOS
resource "aws_db_security_group" "default" {
    name        = "default"
    description = "default"

    ingress {
        security_group_name     = "default"
        security_group_id       = "sg-1234abcd"
        security_group_owner_id = "123456789012"
    }

}

resource "aws_db_security_group" "sgfoobar" {
    name        = "sgfoobar"
    description = "foobar group"

    ingress {
        security_group_name     = "foobar"
        security_group_id       = "sg-5678efgh"
        security_group_owner_id = "3456789012"
    }

}

        EOS
        end
      end

      describe ".tfstate" do
        xit "should raise NotImplementedError" do
          expect do
            described_class.tfstate(json)
          end.to raise_error NotImplementedError
        end
      end
    end
  end
end

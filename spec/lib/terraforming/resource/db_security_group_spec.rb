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
        it "should generate tfstate" do
          expect(described_class.tfstate(json)).to eq JSON.pretty_generate({
            "aws_db_security_group.default" => {
              "type" => "aws_db_security_group",
              "primary" => {
                "id" => "default",
                "attributes" => {
                  "db_subnet_group_name" => "default",
                  "id" => "default",
                  "ingress.#" => "1",
                  "name" => "default",
                }
              }
            },
            "aws_db_security_group.sgfoobar" => {
              "type" => "aws_db_security_group",
              "primary" => {
                "id" => "sgfoobar",
                "attributes" => {
                  "db_subnet_group_name" => "sgfoobar",
                  "id" => "sgfoobar",
                  "ingress.#" => "1",
                  "name" => "sgfoobar",
                }
              }
            }
          })
        end
      end
    end
  end
end

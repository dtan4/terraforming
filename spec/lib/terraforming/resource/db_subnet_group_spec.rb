require "spec_helper"

module Terraforming::Resource
  describe DBSubnetGroup do
    let(:json) do
      JSON.parse(open(fixture_path("rds/describe-db-subnet-groups")).read)
    end

    describe ".tf" do
      it "should generate tf" do
        expect(described_class.tf(json)).to eq <<-EOS
resource "aws_db_subnet_group" "hoge" {
    name        = "hoge"
    description = "DB subnet group hoge"
    subnet_ids  = ["subnet-1234abcd", "subnet-5678efgh"]
}

resource "aws_db_subnet_group" "fuga" {
    name        = "fuga"
    description = "DB subnet group fuga"
    subnet_ids  = ["subnet-9012ijkl", "subnet-3456mnop"]
}

        EOS
      end
    end

    describe ".tfstate" do
      it "should raise NotImplementedError" do
        expect do
          expect(described_class.tfstate(json))
        end.to raise_error NotImplementedError
      end
    end
  end
end

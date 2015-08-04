require "spec_helper"

module Terraforming
  describe CLI do
    shared_examples "CLI examples" do
      before do
        allow(STDOUT).to receive(:puts).and_return(nil)
      end

      context "without --tfstate" do
        it "should export DBParameterGroup tf" do
          expect(klass).to receive(:tf)
          described_class.new.invoke(command, [], {})
        end
      end

      context "with --tfstate" do
        it "should export DBParameterGroup tfstate" do
          expect(klass).to receive(:tfstate).with(no_args)
          described_class.new.invoke(command, [], { tfstate: true })
        end
      end

      context "with --tfstate --merge TFSTATE" do
        it "should export merged DBParameterGroup tfstate" do
          expect(klass).to receive(:tfstate).with(tfstate_base: tfstate_fixture)
          described_class.new.invoke(command, [], { tfstate: true, merge: tfstate_fixture_path })
        end
      end
    end

    describe "dbpg" do
      let(:klass)   { Terraforming::Resource::DBParameterGroup }
      let(:command) { :dbpg }

      it_behaves_like "CLI examples"
    end

    describe "dbsg" do
      let(:klass)   { Terraforming::Resource::DBSecurityGroup }
      let(:command) { :dbsg }

      it_behaves_like "CLI examples"
    end

    describe "dbsn" do
      let(:klass)   { Terraforming::Resource::DBSubnetGroup }
      let(:command) { :dbsn }

      it_behaves_like "CLI examples"
    end

    describe "ec2" do
      let(:klass)   { Terraforming::Resource::EC2 }
      let(:command) { :ec2 }

      it_behaves_like "CLI examples"
    end

    describe "ecc" do
      let(:klass)   { Terraforming::Resource::ElastiCacheCluster }
      let(:command) { :ecc }

      it_behaves_like "CLI examples"
    end

    describe "ecsn" do
      let(:klass)   { Terraforming::Resource::ElastiCacheSubnetGroup }
      let(:command) { :ecsn }

      it_behaves_like "CLI examples"
    end

    describe "elb" do
      let(:klass)   { Terraforming::Resource::ELB }
      let(:command) { :elb }

      it_behaves_like "CLI examples"
    end

    describe "iamg" do
      let(:klass)   { Terraforming::Resource::IAMGroup }
      let(:command) { :iamg }

      it_behaves_like "CLI examples"
    end

    describe "iamgm" do
      let(:klass)   { Terraforming::Resource::IAMGroupMembership }
      let(:command) { :iamgm }

      it_behaves_like "CLI examples"
    end

    describe "iamgp" do
      let(:klass)   { Terraforming::Resource::IAMGroupPolicy }
      let(:command) { :iamgp }

      it_behaves_like "CLI examples"
    end

    describe "iamip" do
      let(:klass)   { Terraforming::Resource::IAMInstanceProfile }
      let(:command) { :iamip }

      it_behaves_like "CLI examples"
    end

    describe "iamp" do
      let(:klass)   { Terraforming::Resource::IAMPolicy }
      let(:command) { :iamp }

      it_behaves_like "CLI examples"
    end

    describe "iamr" do
      let(:klass)   { Terraforming::Resource::IAMRole }
      let(:command) { :iamr }

      it_behaves_like "CLI examples"
    end

    describe "iamrp" do
      let(:klass)   { Terraforming::Resource::IAMRolePolicy }
      let(:command) { :iamrp }

      it_behaves_like "CLI examples"
    end

    describe "iamu" do
      let(:klass)   { Terraforming::Resource::IAMUser }
      let(:command) { :iamu }

      it_behaves_like "CLI examples"
    end

    describe "iamup" do
      let(:klass)   { Terraforming::Resource::IAMUserPolicy }
      let(:command) { :iamup }

      it_behaves_like "CLI examples"
    end

    describe "nacl" do
      let(:klass)   { Terraforming::Resource::NetworkACL }
      let(:command) { :nacl }

      it_behaves_like "CLI examples"
    end

    describe "r53r" do
      let(:klass)   { Terraforming::Resource::Route53Record }
      let(:command) { :r53r }

      it_behaves_like "CLI examples"
    end

    describe "r53z" do
      let(:klass)   { Terraforming::Resource::Route53Zone }
      let(:command) { :r53z }

      it_behaves_like "CLI examples"
    end

    describe "RDS" do
      let(:klass)   { Terraforming::Resource::RDS }
      let(:command) { :rds }

      it_behaves_like "CLI examples"
    end

    describe "s3" do
      let(:klass)   { Terraforming::Resource::S3 }
      let(:command) { :s3 }

      it_behaves_like "CLI examples"
    end

    describe "sg" do
      let(:klass)   { Terraforming::Resource::SecurityGroup }
      let(:command) { :sg }

      it_behaves_like "CLI examples"
    end

    describe "sn" do
      let(:klass)   { Terraforming::Resource::Subnet }
      let(:command) { :sn }

      it_behaves_like "CLI examples"
    end

    describe "vpc" do
      let(:klass)   { Terraforming::Resource::VPC }
      let(:command) { :vpc }

      it_behaves_like "CLI examples"
    end
  end
end

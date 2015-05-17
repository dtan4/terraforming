require "spec_helper"

module Terraforming
  describe CLI do
    describe "dbpg" do
      context "without --tfstate" do
        it "should export DBParameterGroup tf" do
          expect(Terraforming::Resource::DBParameterGroup).to receive(:tf)
          described_class.new.invoke(:dbpg, [], {})
        end
      end

      context "with --tfstate" do
        it "should export DBParameterGroup tfstate" do
          expect(Terraforming::Resource::DBParameterGroup).to receive(:tfstate)
          described_class.new.invoke(:dbpg, [], { tfstate: true })
        end
      end
    end

    describe "dbsg" do
      context "without --tfstate" do
        it "should export DBSecurityGroup tf" do
          expect(Terraforming::Resource::DBSecurityGroup).to receive(:tf)
          described_class.new.invoke(:dbsg, [], {})
        end
      end

      context "with --tfstate" do
        it "should export DBSecurityGroup tfstate" do
          expect(Terraforming::Resource::DBSecurityGroup).to receive(:tfstate)
          described_class.new.invoke(:dbsg, [], { tfstate: true })
        end
      end
    end

    describe "dbsn" do
      context "without --tfstate" do
        it "should export DBSubnetGroup tf" do
          expect(Terraforming::Resource::DBSubnetGroup).to receive(:tf)
          described_class.new.invoke(:dbsn, [], {})
        end
      end

      context "with --tfstate" do
        it "should export DBSubnetGroup tfstate" do
          expect(Terraforming::Resource::DBSubnetGroup).to receive(:tfstate)
          described_class.new.invoke(:dbsn, [], { tfstate: true })
        end
      end
    end

    describe "ec2" do
      context "without --tfstate" do
        it "should export EC2 tf" do
          expect(Terraforming::Resource::EC2).to receive(:tf)
          described_class.new.invoke(:ec2, [], {})
        end
      end

      context "with --tfstate" do
        it "should export EC2 tfstate" do
          expect(Terraforming::Resource::EC2).to receive(:tfstate)
          described_class.new.invoke(:ec2, [], { tfstate: true })
        end
      end
    end

    describe "elb" do
      context "without --tfstate" do
        it "should export ELB tf" do
          expect(Terraforming::Resource::ELB).to receive(:tf)
          described_class.new.invoke(:elb, [], {})
        end
      end

      context "with --tfstate" do
        it "should export ELB tfstate" do
          expect(Terraforming::Resource::ELB).to receive(:tfstate)
          described_class.new.invoke(:elb, [], { tfstate: true })
        end
      end
    end

    describe "iamg" do
      context "without --tfstate" do
        it "should export IAM group tf" do
          expect(Terraforming::Resource::IAMGroup).to receive(:tf)
          described_class.new.invoke(:iamg, [], {})
        end
      end

      context "with --tfstate" do
        it "should export IAM group tfstate" do
          expect(Terraforming::Resource::IAMGroup).to receive(:tfstate)
          described_class.new.invoke(:iamg, [], { tfstate: true })
        end
      end
    end

    describe "iamgp" do
      context "without --tfstate" do
        it "should export IAM group policy tf" do
          expect(Terraforming::Resource::IAMGroupPolicy).to receive(:tf)
          described_class.new.invoke(:iamgp, [], {})
        end
      end

      context "with --tfstate" do
        it "should export IAM group policy tfstate" do
          expect(Terraforming::Resource::IAMGroupPolicy).to receive(:tfstate)
          described_class.new.invoke(:iamgp, [], { tfstate: true })
        end
      end
    end

    describe "iamp" do
      context "without --tfstate" do
        it "should export IAM policy tf" do
          expect(Terraforming::Resource::IAMPolicy).to receive(:tf)
          described_class.new.invoke(:iamp, [], {})
        end
      end

      context "with --tfstate" do
        it "should export IAM policy tfstate" do
          expect(Terraforming::Resource::IAMPolicy).to receive(:tfstate)
          described_class.new.invoke(:iamp, [], { tfstate: true })
        end
      end
    end

    describe "iamu" do
      context "without --tfstate" do
        it "should export IAM user tf" do
          expect(Terraforming::Resource::IAMUser).to receive(:tf)
          described_class.new.invoke(:iamu, [], {})
        end
      end

      context "with --tfstate" do
        it "should export IAM user tfstate" do
          expect(Terraforming::Resource::IAMUser).to receive(:tfstate)
          described_class.new.invoke(:iamu, [], { tfstate: true })
        end
      end
    end

    describe "iamup" do
      context "without --tfstate" do
        it "should export IAM user policy tf" do
          expect(Terraforming::Resource::IAMUserPolicy).to receive(:tf)
          described_class.new.invoke(:iamup, [], {})
        end
      end

      context "with --tfstate" do
        it "should export IAM user policy tfstate" do
          expect(Terraforming::Resource::IAMUserPolicy).to receive(:tfstate)
          described_class.new.invoke(:iamup, [], { tfstate: true })
        end
      end
    end

    describe "nacl" do
      context "without --tfstate" do
        it "should export NetworkACL tf" do
          expect(Terraforming::Resource::NetworkACL).to receive(:tf)
          described_class.new.invoke(:nacl, [], {})
        end
      end

      context "with --tfstate" do
        it "should export NetworkACL tfstate" do
          expect(Terraforming::Resource::NetworkACL).to receive(:tfstate)
          described_class.new.invoke(:nacl, [], { tfstate: true })
        end
      end
    end

    describe "r53r" do
      context "without --tfstate" do
        it "should export Route53Record tf" do
          expect(Terraforming::Resource::Route53Record).to receive(:tf)
          described_class.new.invoke(:r53r, [], {})
        end
      end

      context "with --tfstate" do
        it "should export Route53Record tfstate" do
          expect(Terraforming::Resource::Route53Record).to receive(:tfstate)
          described_class.new.invoke(:r53r, [], { tfstate: true })
        end
      end
    end

    describe "r53z" do
      context "without --tfstate" do
        it "should export Route53Zone tf" do
          expect(Terraforming::Resource::Route53Zone).to receive(:tf)
          described_class.new.invoke(:r53z, [], {})
        end
      end

      context "with --tfstate" do
        it "should export Route53Zone tfstate" do
          expect(Terraforming::Resource::Route53Zone).to receive(:tfstate)
          described_class.new.invoke(:r53z, [], { tfstate: true })
        end
      end
    end

    describe "RDS" do
      context "without --tfstate" do
        it "should export RDS tf" do
          expect(Terraforming::Resource::RDS).to receive(:tf)
          described_class.new.invoke(:rds, [], {})
        end
      end

      context "with --tfstate" do
        it "should export RDS tfstate" do
          expect(Terraforming::Resource::RDS).to receive(:tfstate)
          described_class.new.invoke(:rds, [], { tfstate: true })
        end
      end
    end

    describe "s3" do
      context "without --tfstate" do
        it "should export S3 tf" do
          expect(Terraforming::Resource::S3).to receive(:tf)
          described_class.new.invoke(:s3, [], {})
        end
      end

      context "with --tfstate" do
        it "should export S3 tfstate" do
          expect(Terraforming::Resource::S3).to receive(:tfstate)
          described_class.new.invoke(:s3, [], { tfstate: true })
        end
      end
    end

    describe "sg" do
      context "without --tfstate" do
        it "should export SecurityGroup tf" do
          expect(Terraforming::Resource::SecurityGroup).to receive(:tf)
          described_class.new.invoke(:sg, [], {})
        end
      end

      context "with --tfstate" do
        it "should export SecurityGroup tfstate" do
          expect(Terraforming::Resource::SecurityGroup).to receive(:tfstate)
          described_class.new.invoke(:sg, [], { tfstate: true })
        end
      end
    end

    describe "sn" do
      context "without --tfstate" do
        it "should export SecurityGroup tf" do
          expect(Terraforming::Resource::Subnet).to receive(:tf)
          described_class.new.invoke(:sn, [], {})
        end
      end

      context "with --tfstate" do
        it "should export SecurityGroup tfstate" do
          expect(Terraforming::Resource::Subnet).to receive(:tfstate)
          described_class.new.invoke(:sn, [], { tfstate: true })
        end
      end
    end

    describe "vpc" do
      context "without --tfstate" do
        it "should export VPC tf" do
          expect(Terraforming::Resource::VPC).to receive(:tf)
          described_class.new.invoke(:vpc, [], {})
        end
      end

      context "with --tfstate" do
        it "should export VPC tfstate" do
          expect(Terraforming::Resource::VPC).to receive(:tfstate)
          described_class.new.invoke(:vpc, [], { tfstate: true })
        end
      end
    end
  end
end

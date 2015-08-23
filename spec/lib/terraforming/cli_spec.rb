require "spec_helper"

module Terraforming
  describe CLI do
    context "resources" do
      shared_examples "CLI examples" do
        context "without --tfstate" do
          it "should export tf" do
            expect(klass).to receive(:tf).with(no_args)
            described_class.new.invoke(command, [], {})
          end
        end

        context "with --tfstate" do
          it "should export tfstate" do
            expect(klass).to receive(:tfstate).with(no_args)
            described_class.new.invoke(command, [], { tfstate: true })
          end
        end

        context "with --tfstate --merge TFSTATE" do
          it "should export merged tfstate" do
            expect(klass).to receive(:tfstate).with(no_args)
            described_class.new.invoke(command, [], { tfstate: true, merge: tfstate_fixture_path })
          end
        end
      end

      before do
        allow(STDOUT).to receive(:puts).and_return(nil)
        allow(klass).to receive(:tf).and_return("")
        allow(klass).to receive(:tfstate).and_return({})
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

      describe "nif" do
        let(:klass)   { Terraforming::Resource::NetworkInterface }
        let(:command) { :nif }

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

    context "flush to stdout" do
      describe "s3" do
        let(:klass)   { Terraforming::Resource::S3 }
        let(:command) { :s3 }

        let(:tf) do
          <<-EOS
resource "aws_s3_bucket" "hoge" {
    bucket = "hoge"
    acl    = "private"
}

resource "aws_s3_bucket" "fuga" {
    bucket = "fuga"
    acl    = "private"
}

          EOS
        end

        let(:tfstate) do
          {
            "aws_s3_bucket.hoge" => {
              "type" => "aws_s3_bucket",
              "primary" => {
                "id" => "hoge",
                "attributes" => {
                  "acl" => "private",
                  "bucket" => "hoge",
                  "id" => "hoge"
                }
              }
            },
            "aws_s3_bucket.fuga" => {
              "type" => "aws_s3_bucket",
              "primary" => {
                "id" => "fuga",
                "attributes" => {
                  "acl" => "private",
                  "bucket" => "fuga",
                  "id" => "fuga"
                }
              }
            }
          }
        end

        let(:initial_tfstate) do
          {
            "version" => 1,
            "serial" => 1,
            "modules" => [
              {
                "path" => [
                  "root"
                ],
                "outputs" => {},
                "resources" => {
                  "aws_s3_bucket.hoge" => {
                    "type" => "aws_s3_bucket",
                    "primary" => {
                      "id" => "hoge",
                      "attributes" => {
                        "acl" => "private",
                        "bucket" => "hoge",
                        "id" => "hoge"
                      }
                    }
                  },
                  "aws_s3_bucket.fuga" => {
                    "type" => "aws_s3_bucket",
                    "primary" => {
                      "id" => "fuga",
                      "attributes" => {
                        "acl" => "private",
                        "bucket" => "fuga",
                        "id" => "fuga"
                      }
                    }
                  },
                }
              }
            ]
          }
        end

        let(:merged_tfstate) do
          {
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
                  "aws_s3_bucket.hoge" => {
                    "type" => "aws_s3_bucket",
                    "primary" => {
                      "id" => "hoge",
                      "attributes" => {
                        "acl" => "private",
                        "bucket" => "hoge",
                        "id" => "hoge"
                      }
                    }
                  },
                  "aws_s3_bucket.fuga" => {
                    "type" => "aws_s3_bucket",
                    "primary" => {
                      "id" => "fuga",
                      "attributes" => {
                        "acl" => "private",
                        "bucket" => "fuga",
                        "id" => "fuga"
                      }
                    }
                  },
                }
              }
            ]
          }
        end

        before do
          allow(klass).to receive(:tf).and_return(tf)
          allow(klass).to receive(:tfstate).and_return(tfstate)
        end

        context "without --tfstate" do
          it "should flush tf to stdout" do
            expect(STDOUT).to receive(:puts).with(tf)
            described_class.new.invoke(command, [], {})
          end
        end

        context "with --tfstate" do
          it "should flush state to stdout" do
            expect(STDOUT).to receive(:puts).with(JSON.pretty_generate(initial_tfstate))
            described_class.new.invoke(command, [], { tfstate: true })
          end
        end

        context "with --tfstate --merge TFSTATE" do
          it "should flush merged tfstate to stdout" do
            expect(STDOUT).to receive(:puts).with(JSON.pretty_generate(merged_tfstate))
            described_class.new.invoke(command, [], { tfstate: true, merge: tfstate_fixture_path })
          end
        end

        context "with --tfstate --merge TFSTATE --overwrite" do
           before do
            @tmp_tfstate = Tempfile.new("tfstate")
            @tmp_tfstate.write(open(tfstate_fixture_path).read)
            @tmp_tfstate.flush
          end

          it "should overwrite passed tfstate" do
            described_class.new.invoke(command, [], { tfstate: true, merge: @tmp_tfstate.path, overwrite: true })
            expect(open(@tmp_tfstate.path).read).to eq JSON.pretty_generate(merged_tfstate)
          end

          after do
            @tmp_tfstate.close
            @tmp_tfstate.unlink
          end
        end
      end
    end
  end
end

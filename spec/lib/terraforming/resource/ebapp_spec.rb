require "spec_helper"

module Terraforming
  module Resource
    describe ElasticBeanstalkApplication do
      let(:client) do
        Aws::ElasticBeanstalk::Client.new(stub_responses: true)
      end

      let(:applications) do
        [
          {
            application_name: "hoge",
            description: "an elastic beanstalk application",
            date_created: Time.parse("2016-09-01 09:15:39 UTC"),
            date_updated: Time.parse("2016-09-01 09:15:39 UTC"),
            versions: [],
            configuration_templates: []
          }
        ]
      end

      before do
        client.stub_responses(:describe_applications, applications: applications)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_elastic_beanstalk_application" "hoge" {
  name = "hoge"
  description = "an elastic beanstalk application"
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_elastic_beanstalk_application.hoge" => {
              "type" => "aws_elastic_beanstalk_application",
              "primary" => {
                "id" => "hoge",
                "attributes" => {
                  "name" => "hoge",
                  "description" => "an elastic beanstalk application"
                },
                "meta" => {
                  "schema_version" => "1"
                }
              }
            }
          })
        end
      end
    end
  end
end

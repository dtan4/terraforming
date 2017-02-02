require "spec_helper"

module Terraforming
  module Resource
    describe ElasticBeanstalkEnvironment do
      let(:client) do
        Aws::ElasticBeanstalk::Client.new(stub_responses: true)
      end

      let(:environments) do
        [
          {
            environment_name: "hoge-env",
            environment_id: "e-abcde1234",
            application_name: "hoge",
            version_label: "hoge1",
            solution_stack_name: "64bit Amazon Linux 2016.03 v2.1.1 running Tomcat 8 Java 8",
            template_name: nil,
            description: "Description of hoge",
            endpoint_url: "awseb-e-x-AWSEBsdfsfsdf.us-east-1.elb.amazonaws.com",
            cname: "hoge-env.us-east-1.elasticbeanstalk.com",
            date_created: Time.parse("2016-06-03 13:18:00 UTC"),
            date_updated: Time.parse("2016-06-29 08:57:53 UTC"),
            status: "Ready",
            abortable_operation_in_progress: false,
            health: "Green",
            health_status: "Ok",
            #resources: "",
            tier: { name: "WebServer", type: "Standard", version: " "},
            environment_links: []
          }
        ]
      end

      let(:hoge_settings) do
        [
          {
            application_name: "hoge", 
            date_created: Time.parse("2016-06-03 13:18:00 UTC"),
            date_updated: Time.parse("2016-06-29 08:57:53 UTC"),
            deployment_status: "deployed", 
            description: "Description of hoge", 
            environment_name: "hoge-env", 
            option_settings: [
                {
                  resource_name: "AWSEBAutoScalingGroup", namespace: "aws:autoscaling:asg", option_name: "Availability Zones", value: "Any"
                },
                {
                  resource_name: "AWSEBAutoScalingGroup", namespace: "aws:autoscaling:asg", option_name: "MinSize", value: "1"
                },
                {
                  resource_name: "AWSEBAutoScalingLaunchConfiguration", namespace: "aws:autoscaling:launchconfiguration", option_name: "RootVolumeIOPS", value: ""
                }
             ], 
            solution_stack_name: "64bit Amazon Linux 2016.03 v2.1.1 running Tomcat 8 Java 8", 
          }, 
        ]
      end

      before do
        client.stub_responses(:describe_environments, environments: environments)
        client.stub_responses(:describe_configuration_settings, configuration_settings: hoge_settings )
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_elastic_beanstalk_environment" "hoge-env" {
  name = "hoge-env"
  application = "hoge"
  solution_stack_name = "64bit Amazon Linux 2016.03 v2.1.1 running Tomcat 8 Java 8"
  description = "Description of hoge"
  cname_prefix = "hoge-env"
  tier = "WebServer"

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Availability Zones"
    value     = "Any"
    resource  = "AWSEBAutoScalingGroup"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
    resource  = "AWSEBAutoScalingGroup"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeIOPS"
    value     = ""
    resource  = "AWSEBAutoScalingLaunchConfiguration"
  }
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_elastic_beanstalk_environment.hoge-env" => {
              "type" => "aws_elastic_beanstalk_environment",
              "primary" => {
                "id" => "hoge-env",
                "attributes" => {
                  "name" => "hoge-env",
                  "description" => "Description of hoge",
                  "application" => "hoge",
                  "cname_prefix" => "hoge-env",
                  "tier" => "WebServer",
                  "solution_stack_name" => "64bit Amazon Linux 2016.03 v2.1.1 running Tomcat 8 Java 8",
                  "settings.#" => "3",
                  "setting.3844072155.namespace"=>"aws:autoscaling:asg",
                  "setting.3844072155.name"=>"Availability Zones",
                  "setting.3844072155.value"=>"Any",
                  "setting.3844072155.resource"=>"AWSEBAutoScalingGroup",
                  "setting.277258267.namespace"=>"aws:autoscaling:asg",
                  "setting.277258267.name"=>"MinSize",
                  "setting.277258267.value"=>"1",
                  "setting.277258267.resource"=>"AWSEBAutoScalingGroup",
                  "setting.592614524.namespace"=>"aws:autoscaling:launchconfiguration",
                  "setting.592614524.name"=>"RootVolumeIOPS",
                  "setting.592614524.value"=>"",
                  "setting.592614524.resource"=>"AWSEBAutoScalingLaunchConfiguration"
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

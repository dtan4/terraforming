module Terraforming
  module Resource
    class LambdaFunction
      include Terraforming::Util

      def self.tf(client: Aws::Lambda::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::Lambda::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/lambda_function")
      end

      def tfstate
        db_instances.inject({}) do |resources, instance|
          attributes = {
              "filename" => instance.endpoint.address,
          }
          resources["aws_db_instance.#{module_name_of(instance)}"] = {
              "type" => "aws_db_instance",
              "primary" => {
                  "id" => instance.db_instance_identifier,
                  "attributes" => attributes
              }
          }

          resources
        end
      end

      private

      def lambda_functions
        @client.list_functions.functions
               .inject({}) do |resources, lambda_function|
          func_detail = @client.get_function(
            { function_name: lambda_function.function_name })

          sdownload_lambda_code(
            resources[lambda_function.function_name].url,
            filename)

          resources[lambda_function.function_name] = func_detail

          resources
        end
      end

      def download_lambda_code(url, filename)
        uri = URI.parse(url)

        http_client = Net::HTTP.new(uri.host, uri.port)
        http_client.use_ssl = true
        http_client.ca_file = Aws.config[:ssl_ca_bundle]
        http_client.verify_mode = OpenSSL::SSL::VERIFY_PEER

        http_client.start do |http|
          response = http.get(uri)

          unless response.code == "200"
            raise "Error downloading Lambda Code HTTP Res Code #{response.code}"
          end

          open filename, 'wb' do |io|
            io.write response.body
          end
        end
      end

      def module_name_of(lambda_function)
        normalize_module_name(lambda_function.function_name)
      end
    end
  end
end

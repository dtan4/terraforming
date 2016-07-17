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
        lambda_functions.inject({}) do |resources, instance|
          attributes = {
              "arn" => instance.configuration.function_arn,
              "description" => instance.configuration.description,
              "filename" => "#{instance.configuration.function_name}.zip",
              "function_name" => instance.configuration.function_name,
              "handler" => instance.configuration.handler,
              "id" => instance.configuration.function_name,
              "last_modified" => instance.configuration
                                         .last_modified
                                         .strftime("%FT%T%z"),
              "memory_size" => instance.configuration.memory_size.to_s,
              "role" => instance.configuration.role,
              "runtime" => instance.configuration.runtime,
              "source_code_hash" => instance.configuration.code_sha_256,
              "timeout" => instance.configuration.timeout.to_s,
          }
          unless instance.configuration.vpc_config.nil?
            # lambda is only supported in one vpc, hardcoding
            attributes["vpc_config.#"] = "1"

            attributes["vpc_config.0.security_group_ids.#"] =
              instance.configuration.vpc_config.security_group_ids.count.to_s
            instance.configuration.vpc_config.security_group_ids.each do |sg|
              crc = Zlib.crc32(sg)
              attributes["vpc_config.0.security_group_ids.#{crc}"] = sg
            end

            attributes["vpc_config.0.subnet_ids.#"] =
              instance.configuration.vpc_config.subnet_ids.count.to_s
            instance.configuration.vpc_config.subnet_ids.each do |sn|
              crc = Zlib.crc32(sn)
              attributes["vpc_config.0.subnet_ids.#{crc}"] = sn
            end
          end
          resources["aws_lambda_function.#{module_name_of(instance)}"] = {
            "type" => "aws_lambda_function",
            "primary" => {
              "id" => instance.configuration.function_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def download_all_lambda_function_code(all_lambda_functions)
        all_lambda_functions.each do |function|
          download_lambda_code(function.code.location,
                               "#{function.configuration.function_name}.zip")
        end
      end

      def lambda_functions_with_code
        functions = lambda_functions
        download_all_lambda_function_code(functions)
        functions
      end

      def lambda_functions
        @client.list_functions.functions.inject([]) do |resources, lf|
          resources.push(@client.get_function(function_name: lf.function_name))
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
        normalize_module_name(lambda_function.configuration.function_name)
      end
    end
  end
end

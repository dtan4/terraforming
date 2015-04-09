module Terraforming::Resource
  class S3
    def self.tf(client = Aws::S3::Client.new)
      Terraforming::Resource.apply_template(client, "tf/s3")
    end

    def self.tfstate(client = Aws::S3::Client.new)
      resources = client.list_buckets.buckets.inject({}) do |result, bucket|
        result["aws_s3_bucket.#{bucket.name}"] = {
          "type" => "aws_s3_bucket",
          "primary" => {
            "id" => bucket.name,
            "attributes" => {
              "acl" => "private",
              "bucket" => bucket.name,
              "id" => bucket.name
            }
          }
        }

        result
      end

      tfstate = {
        "version" => 1,
        "serial" => 84,
        "modules" => {
          "path" => [
            "root"
          ],
          "outputs" => {},
          "resources" => resources
        }
      }

      JSON.pretty_generate(tfstate)
    end
  end
end

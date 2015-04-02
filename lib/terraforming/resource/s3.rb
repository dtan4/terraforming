module Terraforming::Resource
  class S3
    def self.tf(client = Aws::S3::Client)
      ERB.new(open(Terraforming.template_path("tf/s3")).read, nil, "-").result(binding)
    end

    def self.tfstate(client = Aws::S3::Client)
      tfstate_s3_buckets = client.list_buckets.buckets.inject({}) do |result, bucket|
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

      JSON.pretty_generate(tfstate_s3_buckets)
    end
  end
end

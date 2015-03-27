module Terraforming::Resource
  class S3
    def self.tf(data)
      ERB.new(open(Terraforming.template_path("tf/s3")).read).result(binding)
    end

    def self.tfstate(data)
      tfstate_s3_buckets = data['Buckets'].inject({}) do |result, bucket|
        result["aws_s3_bucket.#{bucket['Name']}"] = {
          "type" => "aws_s3_bucket",
          "primary" => {
            "id" => bucket['Name'],
            "attributes" => {
              "acl" => "private",
              "bucket" => bucket['Name'],
              "id" => bucket['Name']
            }
          }
        }
        result
      end

      JSON.pretty_generate(tfstate_s3_buckets)
    end
  end
end

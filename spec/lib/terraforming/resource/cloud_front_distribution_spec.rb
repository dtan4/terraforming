require "spec_helper"

module Terraforming
  module Resource
    describe CloudFrontDistribution do
      let(:client) do
        Aws::CloudFront::Client.new(stub_responses: true)
      end

      let(:list_distributions) do
        {
          distribution_list: {
            marker: "",
            max_items: 100,
            is_truncated: false,
            quantity: 1,
            items: [
              {
                id: "DISTRIBUTIONAB",
                arn: "arn:aws:cloudfront::123456789012:distribution/DISTRIBUTIONAB",
                status: "Deployed",
                last_modified_time: Time.parse("2018-10-06 14:36:13.969 +0000 UTC"),
                domain_name: "abcdefghijklmn.cloudfront.net",
                aliases: {
                  quantity: 1,
                  items: ["example.com"]
                },
                origins: {
                  quantity: 1,
                  items: [{
                    id: "example.com",
                    domain_name: "example.com",
                  }]
                },
                default_cache_behavior: {
                  allowed_methods: {
                    quantity: 2,
                    items: ["HEAD", "GET"],
                    cached_methods: {
                      quantity: 2,
                      items: ["HEAD", "GET"],
                    },
                  },
                  target_origin_id: "example.com",
                  forwarded_values: {
                    query_string: false,
                    cookies: {
                      forward: "none",
                    },
                  },
                  trusted_signers: {
                    enabled: false,
                    quantity: 0,
                  },
                  viewer_protocol_policy: "allow-all",
                  min_ttl: 0,
                  default_ttl: 86400,
                  max_ttl: 31536000,
                  compress: false,
                  smooth_streaming: false,
                },
                cache_behaviors: {
                  quantity: 0,
                },
                custom_error_responses: {
                  quantity: 0,
                },
                comment: "",
                price_class: "PriceClass_All",
                enabled: true,
                viewer_certificate: {
                  cloud_front_default_certificate: true,
                  minimum_protocol_version: "TLSv1",
                  certificate_source: "cloudfront",
                },
                restrictions: {
                  geo_restriction: {
                    quantity: 0,
                    restriction_type: "none",
                  },
                },
                web_acl_id: "",
                http_version: "HTTP2",
                is_ipv6_enabled: true,
              }
            ]
          }
        }
      end

      before do
        client.stub_responses(:list_distributions, list_distributions)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_cloudfront_distribution" "DISTRIBUTIONAB" {
  aliases = ["example.com"]
  enabled = true

  origin {
    domain_name = "example.com"
    origin_id   = "example.com"
  }
  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods = ["HEAD", "GET"]
    compress = false
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    min_ttl = 0
    default_ttl = 86400
    max_ttl = 31536000
    smooth_streaming = false
    target_origin_id = "example.com"
    viewer_protocol_policy = "allow-all"
  }

  viewer_certificate {
    acm_certificate_arn = ""
    cloudfront_default_certificate = true
    minimum_protocol_version = "TLSv1"
    ssl_support_method = ""
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
        EOS
        end
      end


      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_cloudfront_distribution.DISTRIBUTIONAB" => {
              "type" => "aws_cloudfront_distribution",
              "primary" => {
                "id" => "DISTRIBUTIONAB",
                "attributes" => {
                  "arn" => "arn:aws:cloudfront::123456789012:distribution/DISTRIBUTIONAB",
                  "comment" => "",
                  "domain_name" => "abcdefghijklmn.cloudfront.net",
                  "enabled" => true,
                  "http_version" => "HTTP2",
                  "id" => "DISTRIBUTIONAB",
                  "is_ipv6_enabled" => true,
                  "price_class" => "PriceClass_All",
                  "status" => "Deployed"
                }
              }
            }
          })
        end
      end
    end
  end
end

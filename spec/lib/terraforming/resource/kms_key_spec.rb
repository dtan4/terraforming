require "spec_helper"

module Terraforming
  module Resource
    describe KMSKey do
      let(:client) do
        Aws::KMS::Client.new(stub_responses: true)
      end

      let(:keys) do
        [
          {
            key_id: "1234abcd-12ab-34cd-56ef-1234567890ab",
            key_arn: "arn:aws:kms:ap-northeast-1:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab",
          },
          {
            key_id: "abcd1234-ab12-cd34-ef56-abcdef123456",
            key_arn: "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456",
          },
          {
            key_id: "12ab34cd-56ef-12ab-34cd-12ab34cd56ef",
            key_arn: "arn:aws:kms:ap-northeast-1:123456789012:key/12ab34cd-56ef-12ab-34cd-12ab34cd56ef",
          },
          {
            key_id: "ab12cd34-ef56-ab12-cd34-ab12cd34ef56",
            key_arn: "arn:aws:kms:ap-northeast-1:123456789012:key/ab12cd34-ef56-ab12-cd34-ab12cd34ef56",
          },
        ]
      end

      let(:hoge_key) do
        {
          key_metadata: {
            aws_account_id: "123456789012",
            key_id: "1234abcd-12ab-34cd-56ef-1234567890ab",
            arn: "arn:aws:kms:ap-northeast-1:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab",
            creation_date: Time.new("2017-01-01 20:12:34 +0900"),
            enabled: true,
            description: "hoge",
            key_usage: "ENCRYPT_DECRYPT",
            key_state: "Enabled",
            origin: "AWS_KMS",
          },
        }
      end

      let(:fuga_key) do
        {
          key_metadata: {
            aws_account_id: "123456789012",
            key_id: "abcd1234-ab12-cd34-ef56-abcdef123456",
            arn: "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456",
            creation_date: Time.new("2017-01-09 12:34:56 +0900"),
            enabled: true,
            description: "fuga",
            key_usage: "ENCRYPT_DECRYPT",
            key_state: "Enabled",
            origin: "AWS_KMS",
          },
        }
      end

      let(:foobar_key) do
        {
          key_metadata: {
            aws_account_id: "123456789012",
            key_id: "ab12cd34-ef56-ab12-cd34-ab12cd34ef56",
            arn: "arn:aws:kms:ap-northeast-1:123456789012:key/ab12cd34-ef56-ab12-cd34-ab12cd34ef56",
            creation_date: Time.new("2017-09-09 12:34:56 +0900"),
            enabled: true,
            description: "Default master key that protects my ACM private keys when no other key is foobar",
            key_usage: "ENCRYPT_DECRYPT",
            key_state: "PendingImport",
            origin: "EXTERNAL",
          },
        }
      end

      let(:aliases) do
        [
          {
            alias_name: "alias/aws/acm",
            alias_arn: "arn:aws:kms:ap-northeast-1:123456789012:alias/aws/acm",
            target_key_id: "12ab34cd-56ef-12ab-34cd-12ab34cd56ef"
          },
          {
            alias_name: "alias/hoge",
            alias_arn: "arn:aws:kms:ap-northeast-1:123456789012:alias/hoge",
            target_key_id: "1234abcd-12ab-34cd-56ef-1234567890ab"
          },
          {
            alias_name: "alias/fuga",
            alias_arn: "arn:aws:kms:ap-northeast-1:123456789012:alias/fuga",
            target_key_id: "abcd1234-ab12-cd34-ef56-abcdef123456"
          },
          {
            alias_name: "alias/foobar",
            alias_arn: "arn:aws:kms:ap-northeast-1:123456789012:alias/foobar",
            target_key_id: "ab12cd34-ef56-ab12-cd34-ab12cd34ef56"
          },
        ]
      end

      let(:hoge_policies) do
        {
          policy_names: ["default"],
        }
      end

      let(:fuga_policies) do
        {
          policy_names: ["default"],
        }
      end

      let(:hoge_policy) do
        {
          policy: <<-EOS,
{
  "Version" : "2012-10-17",
  "Id" : "key-default-1",
  "Statement" : [ {
    "Sid" : "Enable IAM User Permissions",
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : "arn:aws:iam::123456789012:root"
    },
    "Action" : "kms:*",
    "Resource" : "*"
  } ]
}
EOS
        }
      end

      let(:fuga_policy) do
        {
          policy: <<-EOS,
{
  "Version" : "2012-10-17",
  "Id" : "key-consolepolicy-2",
  "Statement" : [ {
    "Sid" : "Enable IAM User Permissions",
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : "arn:aws:iam::123456789012:root"
    },
    "Action" : "kms:*",
    "Resource" : "*"
  }, {
    "Sid" : "Allow access for Key Administrators",
    "Effect" : "Allow",
    "Action" : [ "kms:Create*", "kms:Describe*", "kms:Enable*", "kms:List*", "kms:Put*", "kms:Update*", "kms:Revoke*", "kms:Disable*", "kms:Get*", "kms:Delete*", "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion" ],
    "Resource" : "*"
  }, {
    "Sid" : "Allow use of the key",
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : [ "arn:aws:iam::123456789012:user/user1", "arn:aws:iam::123456789012:user/user2" ]
    },
    "Action" : [ "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey" ],
    "Resource" : "*"
  }, {
    "Sid" : "Allow attachment of persistent resources",
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : [ "arn:aws:iam::123456789012:user/user1", "arn:aws:iam::123456789012:user/user2" ]
    },
    "Action" : [ "kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant" ],
    "Resource" : "*",
    "Condition" : {
      "Bool" : {
        "kms:GrantIsForAWSResource" : "true"
      }
    }

  } ]
}
EOS
        }
      end

      let(:hoge_key_rotation_status) do
        {
          key_rotation_enabled: true,
        }
      end

      let(:fuga_key_rotation_status) do
        {
          key_rotation_enabled: false,
        }
      end

      before do
        client.stub_responses(:list_keys, keys: keys)
        client.stub_responses(:list_aliases, aliases: aliases)
        client.stub_responses(:describe_key, [hoge_key, fuga_key, foobar_key])
        client.stub_responses(:list_key_policies, [hoge_policies, fuga_policies])
        client.stub_responses(:get_key_policy, [hoge_policy, fuga_policy])
        client.stub_responses(:get_key_rotation_status, [hoge_key_rotation_status, fuga_key_rotation_status])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_kms_key" "1234abcd-12ab-34cd-56ef-1234567890ab" {
    description             = "hoge"
    key_usage               = "ENCRYPT_DECRYPT"
    is_enabled              = true
    enable_key_rotation     = true

    policy = <<POLICY
{
  "Version" : "2012-10-17",
  "Id" : "key-default-1",
  "Statement" : [ {
    "Sid" : "Enable IAM User Permissions",
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : "arn:aws:iam::123456789012:root"
    },
    "Action" : "kms:*",
    "Resource" : "*"
  } ]
}
POLICY
}

resource "aws_kms_key" "abcd1234-ab12-cd34-ef56-abcdef123456" {
    description             = "fuga"
    key_usage               = "ENCRYPT_DECRYPT"
    is_enabled              = true
    enable_key_rotation     = false

    policy = <<POLICY
{
  "Version" : "2012-10-17",
  "Id" : "key-consolepolicy-2",
  "Statement" : [ {
    "Sid" : "Enable IAM User Permissions",
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : "arn:aws:iam::123456789012:root"
    },
    "Action" : "kms:*",
    "Resource" : "*"
  }, {
    "Sid" : "Allow access for Key Administrators",
    "Effect" : "Allow",
    "Action" : [ "kms:Create*", "kms:Describe*", "kms:Enable*", "kms:List*", "kms:Put*", "kms:Update*", "kms:Revoke*", "kms:Disable*", "kms:Get*", "kms:Delete*", "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion" ],
    "Resource" : "*"
  }, {
    "Sid" : "Allow use of the key",
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : [ "arn:aws:iam::123456789012:user/user1", "arn:aws:iam::123456789012:user/user2" ]
    },
    "Action" : [ "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey" ],
    "Resource" : "*"
  }, {
    "Sid" : "Allow attachment of persistent resources",
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : [ "arn:aws:iam::123456789012:user/user1", "arn:aws:iam::123456789012:user/user2" ]
    },
    "Action" : [ "kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant" ],
    "Resource" : "*",
    "Condition" : {
      "Bool" : {
        "kms:GrantIsForAWSResource" : "true"
      }
    }

  } ]
}
POLICY
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_kms_key.1234abcd-12ab-34cd-56ef-1234567890ab" => {
              "type" => "aws_kms_key",
              "primary" => {
                "id" => "1234abcd-12ab-34cd-56ef-1234567890ab",
                "attributes" => {
                  "arn" => "arn:aws:kms:ap-northeast-1:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab",
                  "description" => "hoge",
                  "enable_key_rotation" => "true",
                  "id" => "1234abcd-12ab-34cd-56ef-1234567890ab",
                  "is_enabled" => "true",
                  "key_id" => "1234abcd-12ab-34cd-56ef-1234567890ab",
                  "key_usage" => "ENCRYPT_DECRYPT",
                  "policy" => "{\n  \"Version\" : \"2012-10-17\",\n  \"Id\" : \"key-default-1\",\n  \"Statement\" : [ {\n    \"Sid\" : \"Enable IAM User Permissions\",\n    \"Effect\" : \"Allow\",\n    \"Principal\" : {\n      \"AWS\" : \"arn:aws:iam::123456789012:root\"\n    },\n    \"Action\" : \"kms:*\",\n    \"Resource\" : \"*\"\n  } ]\n}\n",
                }
              }
            },
            "aws_kms_key.abcd1234-ab12-cd34-ef56-abcdef123456" => {
              "type" => "aws_kms_key",
              "primary" => {
                "id" => "abcd1234-ab12-cd34-ef56-abcdef123456",
                "attributes" => {
                  "arn" => "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456",
                  "description" => "fuga",
                  "enable_key_rotation" => "false",
                  "id" => "abcd1234-ab12-cd34-ef56-abcdef123456",
                  "is_enabled" => "true",
                  "key_id" => "abcd1234-ab12-cd34-ef56-abcdef123456",
                  "key_usage" => "ENCRYPT_DECRYPT",
                  "policy" => "{\n  \"Version\" : \"2012-10-17\",\n  \"Id\" : \"key-consolepolicy-2\",\n  \"Statement\" : [ {\n    \"Sid\" : \"Enable IAM User Permissions\",\n    \"Effect\" : \"Allow\",\n    \"Principal\" : {\n      \"AWS\" : \"arn:aws:iam::123456789012:root\"\n    },\n    \"Action\" : \"kms:*\",\n    \"Resource\" : \"*\"\n  }, {\n    \"Sid\" : \"Allow access for Key Administrators\",\n    \"Effect\" : \"Allow\",\n    \"Action\" : [ \"kms:Create*\", \"kms:Describe*\", \"kms:Enable*\", \"kms:List*\", \"kms:Put*\", \"kms:Update*\", \"kms:Revoke*\", \"kms:Disable*\", \"kms:Get*\", \"kms:Delete*\", \"kms:ScheduleKeyDeletion\", \"kms:CancelKeyDeletion\" ],\n    \"Resource\" : \"*\"\n  }, {\n    \"Sid\" : \"Allow use of the key\",\n    \"Effect\" : \"Allow\",\n    \"Principal\" : {\n      \"AWS\" : [ \"arn:aws:iam::123456789012:user/user1\", \"arn:aws:iam::123456789012:user/user2\" ]\n    },\n    \"Action\" : [ \"kms:Encrypt\", \"kms:Decrypt\", \"kms:ReEncrypt*\", \"kms:GenerateDataKey*\", \"kms:DescribeKey\" ],\n    \"Resource\" : \"*\"\n  }, {\n    \"Sid\" : \"Allow attachment of persistent resources\",\n    \"Effect\" : \"Allow\",\n    \"Principal\" : {\n      \"AWS\" : [ \"arn:aws:iam::123456789012:user/user1\", \"arn:aws:iam::123456789012:user/user2\" ]\n    },\n    \"Action\" : [ \"kms:CreateGrant\", \"kms:ListGrants\", \"kms:RevokeGrant\" ],\n    \"Resource\" : \"*\",\n    \"Condition\" : {\n      \"Bool\" : {\n        \"kms:GrantIsForAWSResource\" : \"true\"\n      }\n    }\n\n  } ]\n}\n",
                }
              }
            }
          })
        end
      end
    end
  end
end

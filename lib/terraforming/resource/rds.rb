module Terraforming::Resource
  class RDS
    def self.tf(data)
      ERB.new(open(Terraforming.template_path("tf/rds")).read).result(binding)
    end

    def self.tfstate(data)
      tfstate_db_instances = data['DBInstances'].inject({}) do |result, instance|
        attributes = {
          "address" => instance['Endpoint']['Address'],
          "allocated_storage" => instance['AllocatedStorage'].to_s,
          "availability_zone" => instance['AvailabilityZone'],
          "backup_retention_period" => instance['BackupRetentionPeriod'].to_s,
          "backup_window" => instance['PreferredBackupWindow'],
          "db_subnet_group_name" => instance['DBSubnetGroup'] ? instance['DBSubnetGroup']['DBSubnetGroupName'] : "",
          "endpoint" => instance['Endpoint']['Address'],
          "engine" => instance['Engine'],
          "engine_version" => instance['EngineVersion'],
          "final_snapshot_identifier" => "#{instance['DBInstanceIdentifier']}-final",
          "id" => instance['DBInstanceIdentifier'],
          "identifier" => instance['DBInstanceIdentifier'],
          "instance_class" => instance['DBInstanceClass'],
          "maintenance_window" => instance['PreferredMaintenanceWindow'],
          "multi_az" => instance['MultiAZ'].to_s,
          "name" => instance['DBName'],
          "parameter_group_name" => instance['DBParameterGroups'][0]['DBParameterGroupName'],
          "password" => "xxxxxxxx",
          "port" => instance['Endpoint']['Port'].to_s,
          "publicly_accessible" => instance['PubliclyAccessible'].to_s,
          "security_group_names.#" => instance['DBSecurityGroups'].length.to_s,
          "status" => instance['DBInstanceStatus'],
          "storage_type" => instance['StorageType'],
          "username" => instance['MasterUsername'],
          "vpc_security_group_ids.#" => instance['VpcSecurityGroups'].length.to_s,
        }

        result["aws_db_instance.#{instance['DBInstanceIdentifier']}"] = {
          "type" => "aws_db_instance",
          "primary" => {
            "id" => instance['DBInstanceIdentifier'],
            "attributes" => attributes
          }
        }
        result
      end

      JSON.pretty_generate(tfstate_db_instances)
    end
  end
end

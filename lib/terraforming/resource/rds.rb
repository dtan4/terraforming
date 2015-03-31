module Terraforming::Resource
  class RDS
    def self.tf(client = Aws::RDS::Client)
      ERB.new(open(Terraforming.template_path("tf/rds")).read, nil, "-").result(binding)
    end

    def self.tfstate(client = Aws::RDS::Client)
      tfstate_db_instances = client.describe_db_instances.db_instances.inject({}) do |result, instance|
        attributes = {
          "address" => instance.endpoint.address,
          "allocated_storage" => instance.allocated_storage.to_s,
          "availability_zone" => instance.availability_zone,
          "backup_retention_period" => instance.backup_retention_period.to_s,
          "backup_window" => instance.preferred_backup_window,
          "db_subnet_group_name" => instance.db_subnet_group ? instance.db_subnet_group.db_subnet_group_name : "",
          "endpoint" => instance.endpoint.address,
          "engine" => instance.engine,
          "engine_version" => instance.engine_version,
          "final_snapshot_identifier" => "#{instance.db_instance_identifier}-final",
          "id" => instance.db_instance_identifier,
          "identifier" => instance.db_instance_identifier,
          "instance_class" => instance.db_instance_class,
          "maintenance_window" => instance.preferred_maintenance_window,
          "multi_az" => instance.multi_az.to_s,
          "name" => instance.db_name,
          "parameter_group_name" => instance.db_parameter_groups[0].db_parameter_group_name,
          "password" => "xxxxxxxx",
          "port" => instance.endpoint.port.to_s,
          "publicly_accessible" => instance.publicly_accessible.to_s,
          "security_group_names.#" => instance.db_security_groups.length.to_s,
          "status" => instance.db_instance_status,
          "storage_type" => instance.storage_type,
          "username" => instance.master_username,
          "vpc_security_group_ids.#" => instance.vpc_security_groups.length.to_s,
        }

        result["aws_db_instance.#{instance.db_instance_identifier}"] = {
          "type" => "aws_db_instance",
          "primary" => {
            "id" => instance.db_instance_identifier,
            "attributes" => attributes
          }
        }
        result
      end

      JSON.pretty_generate(tfstate_db_instances)
    end
  end
end

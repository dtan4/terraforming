module Terraforming::Resource
  class DBParameterGroup
    def self.tf(client = Aws::RDS::Client.new)
      # TODO: fetch parameter (describe-db-parameters)
      Terraforming::Resource.apply_template(client, "tf/db_parameter_group")
    end

    def self.tfstate(data)
      # TODO: implement DBParameterGroup.tfstate
      raise NotImplementedError
    end
  end
end

module Terraforming::Resource
  class EC2
    def self.tf(client = Aws::EC2::Client.new)
      Terraforming::Resource.apply_template(client, "tf/ec2")
    end

    def self.tfstate(client = Aws::EC2::Client.new)
      # TODO: implement this
      raise NotImplementedError
    end
  end
end

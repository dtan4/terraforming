module Terraforming::Resource
  class SecurityGroup
    def self.tf(data)
      data['SecurityGroups'].inject([]) do |result, security_group|
        ingresses = security_group['IpPermissions'].map do |permission|
      <<-EOS
    ingress {
        from_port   = #{permission['FromPort'] || 0}
        to_port     = #{permission['ToPort'] || 0}
        protocol    = "#{permission['IpProtocol']}"
        cidr_blocks = #{permission['IpRanges'].map { |range| range['CidrIp'] }.inspect}
    }
      EOS
        end.join("\n")

        egresses = security_group['IpPermissionsEgress'].map do |permission|
      <<-EOS
    egress {
        from_port   = #{permission['FromPort'] || 0}
        to_port     = #{permission['ToPort'] || 0}
        protocol    = "#{permission['IpProtocol']}"
        cidr_blocks = #{permission['IpRanges'].map { |range| range['CidrIp'] }.inspect}
    }
      EOS
        end.join("\n")

        result << <<-EOS
resource "aws_security_group" "#{security_group['GroupName']}" {
    name        = "#{security_group['GroupName']}"
    description = "#{security_group['Description']}"

#{ingresses}
#{egresses}
}
    EOS
      end.join("\n")
    end

    def self.tfstate(data)
      # TODO: implement SecurityGroup.tfstate
      raise NotImplementedError
    end
  end
end

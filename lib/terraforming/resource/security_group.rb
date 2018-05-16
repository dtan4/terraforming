module Terraforming
  module Resource
    class SecurityGroup
      include Terraforming::Util

      module Options
        GROUP_IDS = 'group-ids'
      end

      AVAILABLE_OPTIONS = [
          Options::GROUP_IDS,
      ].freeze

      def self.tf(options={})
        opts = apply_defaults_to_options(options)
        self
            .new(opts[:client], opts)
            .tf
      end

      def self.tfstate(options={})
        opts = apply_defaults_to_options(options)
        self.new(opts[:client], opts).tfstate
      end

      def self.apply_defaults_to_options(options)
        options.dup.tap { |o|
          o[:client] ||= Aws::EC2::Client.new
        }
      end

      def initialize(client, options)
        @client = client
        @group_ids = options[Options::GROUP_IDS]
      end

      def tf
        apply_template(@client, "tf/security_group")
      end

      def tfstate
        security_groups.inject({}) do |resources, security_group|
          attributes = {
            "description" => security_group.description,
            "id" => security_group.group_id,
            "name" => security_group.group_name,
            "owner_id" => security_group.owner_id,
            "vpc_id" => security_group.vpc_id || "",
          }

          attributes.merge!(tags_attributes_of(security_group))
          attributes.merge!(egress_attributes_of(security_group))
          attributes.merge!(ingress_attributes_of(security_group))

          resources["aws_security_group.#{module_name_of(security_group)}"] = {
            "type" => "aws_security_group",
            "primary" => {
              "id" => security_group.group_id,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def ingress_attributes_of(security_group)
        ingresses = dedup_permissions(security_group.ip_permissions, security_group.group_id)
        attributes = { "ingress.#" => ingresses.length.to_s }

        ingresses.each do |permission|
          attributes.merge!(permission_attributes_of(security_group, permission, "ingress"))
        end

        attributes
      end

      def egress_attributes_of(security_group)
        egresses = dedup_permissions(security_group.ip_permissions_egress, security_group.group_id)
        attributes = { "egress.#" => egresses.length.to_s }

        egresses.each do |permission|
          attributes.merge!(permission_attributes_of(security_group, permission, "egress"))
        end

        attributes
      end

      def group_hashcode_of(group)
        Zlib.crc32(group)
      end

      def module_name_of(security_group)
        if security_group.vpc_id.nil?
          normalize_module_name(security_group.group_name.to_s)
        else
          normalize_module_name("#{security_group.vpc_id}-#{security_group.group_name}")
        end
      end

      def permission_attributes_of(security_group, permission, type)
        hashcode = permission_hashcode_of(security_group, permission)
        security_groups = security_groups_in(permission, security_group).reject do |identifier|
          [security_group.group_name, security_group.group_id].include?(identifier)
        end

        attributes = {
          "#{type}.#{hashcode}.from_port" => (permission.from_port || 0).to_s,
          "#{type}.#{hashcode}.to_port" => (permission.to_port || 0).to_s,
          "#{type}.#{hashcode}.protocol" => permission.ip_protocol,
          "#{type}.#{hashcode}.cidr_blocks.#" => permission.ip_ranges.length.to_s,
          "#{type}.#{hashcode}.prefix_list_ids.#" => permission.prefix_list_ids.length.to_s,
          "#{type}.#{hashcode}.security_groups.#" => security_groups.length.to_s,
          "#{type}.#{hashcode}.self" => self_referenced_permission?(security_group, permission).to_s,
        }

        permission.ip_ranges.each_with_index do |range, index|
          attributes["#{type}.#{hashcode}.cidr_blocks.#{index}"] = range.cidr_ip
        end

        permission.prefix_list_ids.each_with_index do |prefix_list, index|
          attributes["#{type}.#{hashcode}.prefix_list_ids.#{index}"] = prefix_list.prefix_list_id
        end

        security_groups.each do |group|
          attributes["#{type}.#{hashcode}.security_groups.#{group_hashcode_of(group)}"] = group
        end

        attributes
      end

      def dedup_permissions(permissions, group_id)
        group_permissions(permissions).inject([]) do |result, (_, perms)|
          group_ids = perms.map(&:user_id_group_pairs).flatten.map(&:group_id)

          if group_ids.length == 1 && group_ids.first == group_id
            result << merge_permissions(perms)
          else
            result.concat(perms)
          end

          result
        end
      end

      def group_permissions(permissions)
        permissions.group_by { |permission| [permission.ip_protocol, permission.to_port, permission.from_port] }
      end

      def merge_permissions(permissions)
        master_permission = permissions.pop

        permissions.each do |permission|
          master_permission.user_id_group_pairs.concat(permission.user_id_group_pairs)
          master_permission.ip_ranges.concat(permission.ip_ranges)
        end

        master_permission
      end

      def permission_hashcode_of(security_group, permission)
        string =
          "#{permission.from_port || 0}-" <<
          "#{permission.to_port || 0}-" <<
          "#{permission.ip_protocol}-" <<
          "#{self_referenced_permission?(security_group, permission)}-"

        permission.ip_ranges.each { |range| string << "#{range.cidr_ip}-" }
        security_groups_in(permission, security_group).each { |group| string << "#{group}-" }

        Zlib.crc32(string)
      end

      def self_referenced_permission?(security_group, permission)
        (security_groups_in(permission, security_group) & [security_group.group_id, security_group.group_name]).any?
      end

      def security_groups
        description = if @group_ids
                        @client.describe_security_groups(group_ids: @group_ids)
                      else
                        @client.describe_security_groups
                      end
        description.map(&:security_groups).flatten
      end

      def security_groups_in(permission, security_group)
        permission.user_id_group_pairs.map do |range|
          # EC2-Classic, same account
          if security_group.owner_id == range.user_id && !range.group_name.nil?
            range.group_name
          # VPC
          elsif security_group.owner_id == range.user_id && range.group_name.nil?
            range.group_id
          # EC2-Classic, other account
          else
            "#{range.user_id}/#{range.group_name || range.group_id}"
          end
        end
      end

      def tags_attributes_of(security_group)
        tags = security_group.tags
        attributes = { "tags.#" => tags.length.to_s }
        tags.each { |tag| attributes["tags.#{tag.key}"] = tag.value }
        attributes
      end
    end
  end
end

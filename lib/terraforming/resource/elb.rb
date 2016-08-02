module Terraforming
  module Resource
    class ELB
      include Terraforming::Util

      def self.tf(client: Aws::ElasticLoadBalancing::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::ElasticLoadBalancing::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/elb")
      end

      def tfstate
        load_balancers.inject({}) do |resources, load_balancer|
          load_balancer_attributes = load_balancer_attributes_of(load_balancer)
          attributes = {
            "availability_zones.#" => load_balancer.availability_zones.length.to_s,
            "connection_draining" => load_balancer_attributes.connection_draining.enabled.to_s,
            "connection_draining_timeout" => load_balancer_attributes.connection_draining.timeout.to_s,
            "cross_zone_load_balancing" => load_balancer_attributes.cross_zone_load_balancing.enabled.to_s,
            "dns_name" => load_balancer.dns_name,
            "id" => load_balancer.load_balancer_name,
            "idle_timeout" => load_balancer_attributes.connection_settings.idle_timeout.to_s,
            "instances.#" => load_balancer.instances.length.to_s,
            "internal" => internal?(load_balancer).to_s,
            "name" => load_balancer.load_balancer_name,
            "source_security_group" => load_balancer.source_security_group.group_name,
          }

          if load_balancer_attributes.access_log.enabled

          end

          attributes.merge!(access_logs_attributes_of(load_balancer_attributes))
          attributes.merge!(healthcheck_attributes_of(load_balancer))
          attributes.merge!(listeners_attributes_of(load_balancer))
          attributes.merge!(sg_attributes_of(load_balancer))
          attributes.merge!(subnets_attributes_of(load_balancer))
          attributes.merge!(instances_attributes_of(load_balancer))
          attributes.merge!(tags_attributes_of(load_balancer))

          resources["aws_elb.#{module_name_of(load_balancer)}"] = {
            "type" => "aws_elb",
            "primary" => {
              "id" => load_balancer.load_balancer_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      def access_logs_attributes_of(load_balancer_attributes)
        access_log = load_balancer_attributes.access_log

        if access_log.enabled
          {
            "access_logs.#" => "1",
            "access_logs.0.bucket" => access_log.s3_bucket_name,
            "access_logs.0.bucket_prefix" => access_log.s3_bucket_prefix,
            "access_logs.0.interval" => access_log.emit_interval.to_s,
          }
        else
          {
            "access_logs.#" => "0",
          }
        end
      end

      def healthcheck_attributes_of(elb)
        hashcode = healthcheck_hashcode_of(elb.health_check)
        attributes = {
          # Now each ELB supports one heatlhcheck
          "health_check.#" => "1",
          "health_check.#{hashcode}.healthy_threshold" => elb.health_check.healthy_threshold.to_s,
          "health_check.#{hashcode}.interval" => elb.health_check.interval.to_s,
          "health_check.#{hashcode}.target" => elb.health_check.target,
          "health_check.#{hashcode}.timeout" => elb.health_check.timeout.to_s,
          "health_check.#{hashcode}.unhealthy_threshold" => elb.health_check.unhealthy_threshold.to_s
        }

        attributes
      end

      def healthcheck_hashcode_of(health_check)
        string =
          "#{health_check.healthy_threshold}-" <<
          "#{health_check.unhealthy_threshold}-" <<
          "#{health_check.target}-" <<
          "#{health_check.interval}-" <<
          "#{health_check.timeout}-"

        Zlib.crc32(string)
      end

      def tags_attributes_of(elb)
        tags = @client.describe_tags(load_balancer_names: [elb.load_balancer_name]).tag_descriptions.first.tags
        attributes = { "tags.#" => tags.length.to_s }

        tags.each do |tag|
          attributes["tags.#{tag.key}"] = tag.value
        end

        attributes
      end

      def instances_attributes_of(elb)
        attributes = { "instances.#" => elb.instances.length.to_s }

        elb.instances.each do |instance|
          attributes["instances.#{Zlib.crc32(instance.instance_id)}"] = instance.instance_id
        end

        attributes
      end

      def subnets_attributes_of(elb)
        attributes = { "subnets.#" => elb.subnets.length.to_s }

        elb.subnets.each do |subnet_id|
          attributes["subnets.#{Zlib.crc32(subnet_id)}"] = subnet_id
        end

        attributes
      end

      def sg_attributes_of(elb)
        attributes = { "security_groups.#" => elb.security_groups.length.to_s }

        elb.security_groups.each do |sg_id|
          attributes["security_groups.#{Zlib.crc32(sg_id)}"] = sg_id
        end

        attributes
      end

      def listeners_attributes_of(elb)
        attributes = { "listener.#" => elb.listener_descriptions.length.to_s }

        elb.listener_descriptions.each do |listener_description|
          attributes.merge!(listener_attributes_of(listener_description.listener))
        end

        attributes
      end

      def listener_attributes_of(listener)
        hashcode = listener_hashcode_of(listener)

        attributes = {
          "listener.#{hashcode}.instance_port" => listener.instance_port.to_s,
          "listener.#{hashcode}.instance_protocol" => listener.instance_protocol.downcase,
          "listener.#{hashcode}.lb_port" => listener.load_balancer_port.to_s,
          "listener.#{hashcode}.lb_protocol" => listener.protocol.downcase,
          "listener.#{hashcode}.ssl_certificate_id" => listener.ssl_certificate_id
        }

        attributes
      end

      def listener_hashcode_of(listener)
        string =
          "#{listener.instance_port}-" <<
          "#{listener.instance_protocol.downcase}-" <<
          "#{listener.load_balancer_port}-" <<
          "#{listener.protocol.downcase}-" <<
          "#{listener.ssl_certificate_id}-"

        Zlib.crc32(string)
      end

      def load_balancers
        @client.describe_load_balancers.map(&:load_balancer_descriptions).flatten
      end

      def load_balancer_attributes_of(load_balancer)
        @client.describe_load_balancer_attributes(load_balancer_name: load_balancer.load_balancer_name).load_balancer_attributes
      end

      def module_name_of(load_balancer)
        normalize_module_name(load_balancer.load_balancer_name)
      end

      def vpc_elb?(load_balancer)
        load_balancer.vpc_id != ""
      end

      def internal?(load_balancer)
        load_balancer.scheme == "internal"
      end
    end
  end
end

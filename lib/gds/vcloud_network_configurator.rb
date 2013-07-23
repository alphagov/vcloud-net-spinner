require 'optparse'
require 'gds/vcloud_network_configurator/edge_gateway'

module Gds
  class VcloudNetworkConfigurator
    def initialize args
      @args = args
      @options = {}
    end

    def execute
      parse @args
      EdgeGateway.new(@options).apply_configuration
    end

    private
    def parse args
      optparser = OptionParser.new do |o|
        o.banner = "Usage: config_edge_gateway [options] API_URL"

        o.on("-u", "--username=U", String, "Vcloud Username") do |v|
          @options[:username] = v
        end

        o.on("-p", "--password=P", String, "Vcloud Password") do |v|
          @options[:password] = v
        end

        o.on("-e", "--env=E", ["preview", "staging", "production"], "Environment: preview | staging | production") do |v|
          @options[:environment] = v
        end

        o.on("-U", "--organization-edgegateway-uuid",
             "UID: This is required to configure edgegateway services. For more info refer to docs/find_organisation_edgegateway_uuid") do |v|
          @options[:org_edgedateway_uuid] = v
        end

        o.on("-c", "--component=c", ["lb", "firewall", "nat"], "Environment: lb|firewall|nat") do |v|
          @options[:component] = v
        end

        o.on("-o", "--organization=o", "Organization: optional. Will default to environment") do |v|
          @options[:organization] = v
        end

      end

      optparser.parse!(@args)
      if !args.empty?
        @options[:api_url] = args[0]
      else
        raise Exception
      end

      @options[:organization] ||= @options[:environment]
    end

  end
end

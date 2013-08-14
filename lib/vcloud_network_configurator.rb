require 'optparse'
require 'component/firewall'
require 'component/load_balancer'
require 'component/nat'
require 'vcloud_network_configurator/edge_gateway'

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
      o.banner = "Usage: vcloud-net-spinner [options] API_URL"
      o.summary_width = 40

      o.on("-u", "--username=U", String, "Vcloud Username") do |v|
        @options[:username] = v
      end

      o.on("-p", "--password=P", String, "Vcloud Password") do |v|
        @options[:password] = v
      end

      o.on("-e", "--env=E", String, "Environment: name by which you would refer your environment as (also used for tree structure)") do |v|
        @options[:environment] = v
      end

      o.on("-U", "--organization-edgegateway-uuid=U",
           "UID: This is required to configure edgegateway services. For more info refer to docs/find_organisation_edgegateway_uuid") do |v|
        @options[:org_edgegateway_uuid] = v
      end

      o.on("-c", "--component=c", ["lb", "firewall", "nat"], "Environment: lb|firewall|nat") do |v|
        @options[:component] = v
      end

      o.on("-o", "--organization=o", "Organization: optional. Will default to environment") do |v|
        @options[:organization] = v
      end

      o.on("-r", "--rule-files file1,file2,file3", Array, "Rules Files: files which will contain the rules for the component provided") do |v|
        @options[:rules_files] = v
      end

      o.on("-i", "--interfaces-files file1,file2,file3", Array, "Interfaces Files: files which will contain interfaces") do |v|
        @options[:interfaces_files] = v
      end
    end

    optparser.parse!(@args)
    if !args.empty?
      @options[:api_url] = args[0]
    else
      raise Exception.new("No API_URL provided. See help for more details")
    end

    @options[:organization] ||= @options[:environment]
  end

end

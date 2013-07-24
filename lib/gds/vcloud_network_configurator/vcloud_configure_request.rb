require "net/http"
module Gds
  class VcloudConfigureRequest
    def initialize vcloud_settings, auth_header, environment, component, rules_directory
      @auth_header = auth_header
      @config_url =  vcloud_settings.edge_gateway_config_url
      @environment = environment
      @component = component
      require "#{rules_directory}/#{@environment}/interfaces"

      require "#{rules_directory}/common_#{component}.rb"
      require "#{rules_directory}/#{@environment}/#{component}"
    end

    def components
      { "firewall" => "Firewall", "nat" => "NAT", "lb" => "LoadBalancer" }
    end

    def submit
      url = URI(@config_url)
      request = Net::HTTP::Post.new url.request_uri
      request['Accept'] = 'application/*+xml;version=5.1'
      request['Content-Type'] = 'application/vnd.vmware.admin.edgeGatewayServiceConfiguration+xml'
      request['x-vcloud-authorization'] = @auth_header

      request.body = Kernel.const_get(components[@component]).generate_xml.to_xml

      puts "Reading configuration from #{@config_file}"
      puts "Submitting request at #{@config_url}\n"

      session = Net::HTTP.new(url.host, url.port)
      session.use_ssl = true
      response = session.start do |http|
        http.request request
      end

      puts "HTTP #{response.code}"
      puts response
      return response
    end
  end
end

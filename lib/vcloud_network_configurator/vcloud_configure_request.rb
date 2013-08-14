require "net/http"
require 'yaml'

class VcloudConfigureRequest
  def initialize vcloud_settings, auth_header, component, rules_files, interfaces_files
    @auth_header = auth_header
    @config_url =  vcloud_settings.edge_gateway_config_url
    @component = component
    @response = nil

    @interfaces = {}
    interfaces_files.each do |ifile|
      @interfaces.merge!(YAML::load_file(ifile)['interfaces']) if File.file?(ifile)
    end if interfaces_files

    rules_files.each do |rfile|
      require rfile if File.file?(rfile)
    end if rules_files
  end

  def components
    { "firewall" => "Firewall", "nat" => "NAT", "lb" => "LoadBalancer" }
  end

  def submit
    generated_xml = Kernel.const_get("Component").const_get(components[@component]).
                      generate_xml(@interfaces)
    abort "No rules found. exiting" if generated_xml.nil?

    url = URI(@config_url)
    request = Net::HTTP::Post.new url.request_uri
    request['Accept'] = VcloudSettings.request_headers['Accept']
    request['Content-Type'] = VcloudSettings.request_headers['Content-Type']
    request['x-vcloud-authorization'] = @auth_header

    request.body = generated_xml.to_xml

    puts "Reading configuration from #{@config_file}"
    puts "Submitting request at #{@config_url}\n"

    session = Net::HTTP.new(url.host, url.port)
    session.use_ssl = true
    response = session.start do |http|
      http.request request
    end

    puts "HTTP #{response.code}"
    puts response
    @response = response
  end

  def success?
    @response.code == "202"
  end

  def response_body
    @response.body
  end
end

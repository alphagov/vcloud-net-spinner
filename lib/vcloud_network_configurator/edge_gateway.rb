require 'vcloud_network_configurator/vcloud_auth_request'
require 'vcloud_network_configurator/vcloud_configure_request'
require 'vcloud_network_configurator/vcloud_check_for_configure_task_request'
require 'vcloud_network_configurator/configure_task'

class EdgeGateway
  def initialize options
    @options = options
    @vcloud_settings = VcloudSettings.new( { url: @options[:api_url], edge_gateway_uuid: @options[:org_edgegateway_uuid] } )
  end

  def apply_configuration
    auth_header = authorize_request
    configure_request = VcloudConfigureRequest.new(@vcloud_settings, auth_header, @options[:environment], @options[:component], @options[:rules_directory])
    configure_request.submit

    if configure_request.success?
      check_for_success auth_header, ConfigureTask.new(configure_request.response_body)
      return true
    else
      puts "Failed to configure the edge gateway"
      return false
    end
  end

  private
  def authorize_request
    auth_request = VcloudAuthRequest.new(@vcloud_settings, "#{@options[:username]}@#{@options[:organization]}", @options[:password])
    auth_request.submit
    abort("Could not authenticate user") unless auth_request.authenticated?

    auth_request.auth_response["x-vcloud-authorization"]
  end

  def check_for_success auth_header, configure_task
    begin
      puts "\n\n\nSleeping for 10 seconds before the next check for success \n\n\n"
      sleep(10) unless ENV['GEM_ENV'] == "test"
      response = VcloudCheckForConfigureTaskRequest.new(auth_header, configure_task.url).submit

      configure_task = ConfigureTask.new(response.body)

      if configure_task.error?
        abort("Failed to configure the edge gateway")
      end

    end while not configure_task.complete?

    puts "\n\n\nSuccessfully configured the edge gateway"
  end
end

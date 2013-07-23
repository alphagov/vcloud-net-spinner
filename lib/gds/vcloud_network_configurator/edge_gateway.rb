require 'gds/vcloud_network_configurator/vcloud_auth_request'
require 'gds/vcloud_network_configurator/vcloud_configure_request'
require 'gds/vcloud_network_configurator/vcloud_check_for_configure_task_request'
require 'gds/vcloud_network_configurator/configure_task'
module Gds
  class EdgeGateway
    def initialize options
      @options = options
      @vcloud_url = VcloudUrl.new( { url: @options[:api_url], edge_gateway_uuid: @option[:org_edgedateway_uuid] } )
    end

    def apply_configuration
      auth_response = VcloudAuthRequest.new(@vcloud_url, "#{@options[:username]}@gds-#{@options[:organization]}", @options[:password]).submit
      if(auth_response.code != "200")
        abort("Could not authenticate user")
      end

      auth_header = auth_response["x-vcloud-authorization"]
      configure_response = VcloudConfigureRequest.new(@vcloud_url, auth_header, @options[:environment], @options[:component], @options[:rules_directory]).submit

      if configure_response.code == "202"
        check_for_success auth_header, ConfigureTask.new(configure_response.body)
      else
        puts "Failed to configure the edge gateway"
      end
    end

    private
    def check_for_success auth_header, configure_task
      begin
        puts "\n\n\nSleeping for 10 seconds before the next check for success \n\n\n"
        sleep(10)
        response = VcloudCheckForConfigureTaskRequest.new(auth_header, configure_task.url).submit

        configure_task = ConfigureTask.new(response.body)

        if configure_task.error?
          abort("Failed to configure the edge gateway")
        end

      end while not configure_task.complete?

      puts "\n\n\nSuccessfully configured the edge gateway"
    end
  end
end

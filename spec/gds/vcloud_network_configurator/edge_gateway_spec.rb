require 'spec_helper'
require 'vcloud_network_configurator/edge_gateway'

module Gds
  describe EdgeGateway do
    it "should abort if vcloud api couldn't authenticate" do
      auth_request = mock()
      VcloudAuthRequest.should_receive(:new).and_return(auth_request)
      auth_request.should_receive(:submit).and_return(mock(:code => "400"))

      eg = EdgeGateway.new({:api_url => 'eggplant.com', :edge_gateway_uuid => '123321'})
      lambda { eg.apply_configuration }.should raise_error(SystemExit)
    end

    it "should authorize and configure changes" do
      vs = mock()
      VcloudSettings.should_receive(:new).
        with({url: 'eggplant.com', edge_gateway_uuid: '123321' }).and_return(vs)

      auth_request = mock()
      VcloudAuthRequest.should_receive(:new).with(vs, "bringle@gds-aubergine", "eggplant").
        and_return(auth_request)
      auth_response = mock(:code => "200")
      auth_response.should_receive(:[]).with('x-vcloud-authorization').and_return('123213')
      auth_request.should_receive(:submit).and_return(auth_response)

      VcloudConfigureRequest.should_receive(:new).
        with(vs, '123213', 'farm', 'firewall', 'path/to/dir').
        and_return(mock(:submit => true, :success? => true, :response_body => nil))

      EdgeGateway.any_instance.stub(:check_for_success => true)

      eg = EdgeGateway.new({:api_url => 'eggplant.com',
                            :org_edgegateway_uuid => '123321',
                            :username => 'bringle',
                            :password => 'eggplant',
                            :environment => 'farm',
                            :organization => 'aubergine',
                            :component => 'firewall',
                            :rules_directory => 'path/to/dir',
      })
      eg.apply_configuration
    end
  end
end

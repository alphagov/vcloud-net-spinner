require 'spec_helper'
require 'vcloud_network_configurator/edge_gateway'

describe EdgeGateway do
  it "should abort if vcloud api couldn't authenticate" do
    auth_request = mock(:authenticated? => false)
    VcloudAuthRequest.should_receive(:new).and_return(auth_request)
    auth_request.should_receive(:submit).and_return(mock())

    eg = EdgeGateway.new({:api_url => 'eggplant.com', :edge_gateway_uuid => '123321'})
    lambda { eg.apply_configuration }.should raise_error(SystemExit)
  end

  it "should authorize and configure changes" do
    vs = mock()
    VcloudSettings.should_receive(:new).
      with({url: 'eggplant.com', edge_gateway_uuid: '123321' }).and_return(vs)

    auth_request = mock(:authenticated? => true, :submit => true)
    VcloudAuthRequest.should_receive(:new).with(vs, "bringle@gds-aubergine", "eggplant").
      and_return(auth_request)
    auth_request.should_receive(:auth_response).and_return({'x-vcloud-authorization' => '123213'})

    VcloudConfigureRequest.should_receive(:new).
      with(vs, '123213', 'farm', 'firewall', 'path/to/rules', 'path/to/interfaces').
      and_return(mock(:submit => true, :success? => true, :response_body => nil))

    EdgeGateway.any_instance.stub(:check_for_success => true)

    eg = EdgeGateway.new({:api_url => 'eggplant.com',
                          :org_edgegateway_uuid => '123321',
                          :username => 'bringle',
                          :password => 'eggplant',
                          :environment => 'farm',
                          :organization => 'gds-aubergine',
                          :component => 'firewall',
                          :rules_files => 'path/to/rules',
                          :interfaces_files => 'path/to/interfaces',
    })
    eg.apply_configuration
  end
end

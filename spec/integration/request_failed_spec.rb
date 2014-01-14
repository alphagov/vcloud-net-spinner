require 'spec_helper'
require 'vcloud_network_configurator'

describe "request failed" do

  before :each do
    WebMock.disable_net_connect!
    WebMock.reset!

    session_url = "https://super%40org-name:man@www.vcloud.eggplant.com/sessions"
    edge_gateway_configure_url = "https://www.vcloud.eggplant.com/admin/edgeGateway/123321/action/configureServices"

    stub_request(:post, session_url).
      with(:headers => {'Accept'=>'application/*+xml;version=5.1', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200,
                :body => File.read('spec/integration/test_data/happy_path_auth_response.xml'),
                :headers => { 'x-vcloud-authorization' => '123321'})

    stub_request(:post, edge_gateway_configure_url).
      with(:body => configure_firewall_xml,
           :headers => { 'Accept'=>'application/*+xml;version=5.1',
                         'Content-Type'=>'application/vnd.vmware.admin.edgeGatewayServiceConfiguration+xml',
                         'User-Agent'=>'Ruby',
                         'X-Vcloud-Authorization'=>'123321' }).
      to_return(:status => 400, :body => 'eep')
  end

  it "should abort on failure" do
    args = ["-u", "super", "-p", "man", "-U", "123321", "-r",
            "spec/integration/test_data/rules_dir/common_firewall.rb,spec/integration/test_data/rules_dir/preview/firewall.rb",
            "-o", "org-name",
            "-c", "firewall", "https://www.vcloud.eggplant.com"]

    configurator = VcloudNetworkConfigurator.new(args)
    expect { configurator.execute }.to raise_error(SystemExit, "Failed to configure the edge gateway")
  end
end

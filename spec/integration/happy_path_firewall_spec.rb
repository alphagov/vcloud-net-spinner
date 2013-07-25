require 'spec_helper'
require 'vcloud_network_configurator'

describe "happy path" do

  before :each do
    WebMock.disable_net_connect!
    WebMock.reset!

    session_url = "https://super%40gds-preview:man@www.vcloud.eggplant.com/sessions"
    edge_gateway_configure_url = "https://www.vcloud.eggplant.com/api/admin/edgeGateway/123321/action/configureServices"
    task_url = "https://www.vcloud.eggplant.com/api/tasks/10"

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
      to_return(:status => 202, :body => configure_task_xml)

    stub_request(:get, task_url).
      with(:headers => {'Accept'=>'application/*+xml;version=5.1', 'User-Agent'=>'Ruby', 'X-Vcloud-Authorization'=>'123321'}).
      to_return(:status => 200, :body => configure_task_xml, :headers => {})
  end

  it "should configure edgegateway successfully" do
    args = ["-u", "super", "-p", "man", "-U", "123321", "-d",
            "spec/integration/test_data/rules_dir", "-e", "preview",
            "-c", "firewall", "https://www.vcloud.eggplant.com"]

    configurator = VcloudNetworkConfigurator.new(args)
    configurator.execute.should be_true
  end
end

def configure_task_xml
%q{<Task href="https://www.vcloud.eggplant.com/api/tasks/10" status="success"></Task>}
end

def configure_firewall_xml
  %q{<?xml version="1.0" encoding="UTF-8"?>
<EdgeGatewayServiceConfiguration xmlns="http://www.vmware.com/vcloud/v1.5" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vmware.com/vcloud/v1.5 http://vendor-api-url.net/v1.5/schema/master.xsd">
  <FirewallService>
    <IsEnabled>true</IsEnabled>
    <DefaultAction>drop</DefaultAction>
    <LogDefaultAction>false</LogDefaultAction>
    <FirewallRule>
      <Id>1</Id>
      <IsEnabled>true</IsEnabled>
      <MatchOnTranslate>false</MatchOnTranslate>
      <Description>allow all boxes to access peppers box on port 22</Description>
      <Policy>allow</Policy>
      <Protocols>
        <Tcp>true</Tcp>
      </Protocols>
      <Port>22</Port>
      <DestinationPortRange>22</DestinationPortRange>
      <DestinationIp>172.11.0.1</DestinationIp>
      <SourcePort>-1</SourcePort>
      <SourcePortRange>Any</SourcePortRange>
      <SourceIp>172.10.0.0/24</SourceIp>
      <EnableLogging>false</EnableLogging>
    </FirewallRule>
  </FirewallService>
</EdgeGatewayServiceConfiguration>
}
end

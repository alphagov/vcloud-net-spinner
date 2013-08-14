require 'spec_helper'
require 'vcloud_network_configurator'

describe "happy path for nat configurations" do

  before :each do
    WebMock.disable_net_connect!
    WebMock.reset!

    session_url = "https://super%40preview:man@www.vcloud.eggplant.com/sessions"
    edge_gateway_configure_url = "https://www.vcloud.eggplant.com/admin/edgeGateway/123321/action/configureServices"
    task_url = "https://www.vcloud.eggplant.com/api/tasks/10"

    stub_request(:post, session_url).
      with(:headers => {'Accept'=>'application/*+xml;version=5.1', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200,
                :body => File.read('spec/integration/test_data/happy_path_auth_response.xml'),
                :headers => { 'x-vcloud-authorization' => '123321'})

    stub_request(:post, edge_gateway_configure_url).
      with(:body => configure_nat_xml,
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
    args = ["-u", "super", "-p", "man", "-U", "123321", "-r",
            "spec/integration/test_data/rules_dir/common_nat.rb,spec/integration/test_data/rules_dir/preview/nat.rb",
            "-i", "spec/integration/test_data/rules_dir/preview/interfaces.yaml",
            "-o", "preview",
            "-c", "nat", "https://www.vcloud.eggplant.com"]

    configurator = VcloudNetworkConfigurator.new(args)
    configurator.execute.should be_true
  end
end

def configure_task_xml
%q{<Task href="https://www.vcloud.eggplant.com/api/tasks/10" status="success"></Task>}
end

def configure_nat_xml
  %q{<?xml version="1.0" encoding="UTF-8"?>
<EdgeGatewayServiceConfiguration xmlns="http://www.vmware.com/vcloud/v1.5" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vmware.com/vcloud/v1.5 http://vendor-api-url.net/v1.5/schema/master.xsd">
  <NatService>
    <IsEnabled>true</IsEnabled>
    <NatRule>
      <RuleType>SNAT</RuleType>
      <IsEnabled>true</IsEnabled>
      <Id>65538</Id>
      <GatewayNatRule>
        <Interface type="application/vnd.vmware.admin.network+xml" name="VDC-1" href="http://interface.vdc-1/19237"/>
        <OriginalIp>internal-ip</OriginalIp>
        <TranslatedIp>external-ip</TranslatedIp>
      </GatewayNatRule>
    </NatRule>
    <NatRule>
      <RuleType>DNAT</RuleType>
      <IsEnabled>true</IsEnabled>
      <Id>65539</Id>
      <GatewayNatRule>
        <Interface type="application/vnd.vmware.admin.network+xml" name="VDC-1" href="http://interface.vdc-1/19237"/>
        <OriginalIp>external-ip</OriginalIp>
        <OriginalPort>22</OriginalPort>
        <TranslatedIp>internal-ip</TranslatedIp>
        <TranslatedPort>22</TranslatedPort>
        <Protocol>tcp</Protocol>
      </GatewayNatRule>
    </NatRule>
  </NatService>
</EdgeGatewayServiceConfiguration>
}
end

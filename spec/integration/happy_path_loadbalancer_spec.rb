require 'spec_helper'
require 'vcloud_network_configurator'

describe "happy path for lb configurations" do

  before :each do
    WebMock.disable_net_connect!
    WebMock.reset!

    session_url = "https://super%40org-name:man@www.vcloud.eggplant.com/sessions"
    edge_gateway_configure_url = "https://www.vcloud.eggplant.com/admin/edgeGateway/123321/action/configureServices"
    task_url = "https://www.vcloud.eggplant.com/api/tasks/10"

    stub_request(:post, session_url).
      with(:headers => {'Accept'=>'application/*+xml;version=5.1', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200,
                :body => File.read('spec/integration/test_data/happy_path_auth_response.xml'),
                :headers => { 'x-vcloud-authorization' => '123321'})

    stub_request(:post, edge_gateway_configure_url).
      with(:body => configure_lb_xml,
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
            "spec/integration/test_data/rules_dir/common_lb.rb,spec/integration/test_data/rules_dir/preview/lb.rb",
            "-i", "spec/integration/test_data/rules_dir/preview/interfaces.yaml",
            "-o", "org-name",
            "-c", "lb", "https://www.vcloud.eggplant.com"]

    configurator = VcloudNetworkConfigurator.new(args)
    configurator.execute.should be_true
  end
end

def configure_task_xml
%q{<Task href="https://www.vcloud.eggplant.com/api/tasks/10" status="success"></Task>}
end

def configure_lb_xml
  %q{<?xml version="1.0" encoding="UTF-8"?>
<EdgeGatewayServiceConfiguration xmlns="http://www.vmware.com/vcloud/v1.5" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vmware.com/vcloud/v1.5 http://vendor-api-url.net/v1.5/schema/master.xsd">
  <LoadBalancerService>
    <IsEnabled>false</IsEnabled>
    <Pool>
      <Name>Frontend pool</Name>
      <ServicePort>
        <IsEnabled>true</IsEnabled>
        <Protocol>HTTP</Protocol>
        <Algorithm>ROUND_ROBIN</Algorithm>
        <Port>80</Port>
        <HealthCheckPort/>
        <HealthCheck>
          <Mode>HTTP</Mode>
          <Uri>/</Uri>
          <HealthThreshold>2</HealthThreshold>
          <UnhealthThreshold>3</UnhealthThreshold>
          <Interval>5</Interval>
          <Timeout>15</Timeout>
        </HealthCheck>
      </ServicePort>
      <ServicePort>
        <IsEnabled>true</IsEnabled>
        <Protocol>HTTPS</Protocol>
        <Algorithm>ROUND_ROBIN</Algorithm>
        <Port>443</Port>
        <HealthCheckPort/>
        <HealthCheck>
          <Mode>SSL</Mode>
          <Uri>/</Uri>
          <HealthThreshold>2</HealthThreshold>
          <UnhealthThreshold>3</UnhealthThreshold>
          <Interval>5</Interval>
          <Timeout>15</Timeout>
        </HealthCheck>
      </ServicePort>
      <ServicePort>
        <IsEnabled>false</IsEnabled>
        <Protocol>TCP</Protocol>
        <Algorithm>ROUND_ROBIN</Algorithm>
        <Port/>
        <HealthCheckPort/>
        <HealthCheck>
          <Mode>TCP</Mode>
          <HealthThreshold>2</HealthThreshold>
          <UnhealthThreshold>3</UnhealthThreshold>
          <Interval>5</Interval>
          <Timeout>15</Timeout>
        </HealthCheck>
      </ServicePort>
      <Member>
        <IpAddress>20.2.0.1</IpAddress>
        <Weight>1</Weight>
        <ServicePort>
          <Protocol>HTTP</Protocol>
          <Port>80</Port>
          <HealthCheckPort/>
        </ServicePort>
        <ServicePort>
          <Protocol>HTTPS</Protocol>
          <Port>443</Port>
          <HealthCheckPort/>
        </ServicePort>
        <ServicePort>
          <Protocol>TCP</Protocol>
          <Port/>
          <HealthCheckPort/>
        </ServicePort>
      </Member>
      <Member>
        <IpAddress>20.3.0.2</IpAddress>
        <Weight>1</Weight>
        <ServicePort>
          <Protocol>HTTP</Protocol>
          <Port>80</Port>
          <HealthCheckPort/>
        </ServicePort>
        <ServicePort>
          <Protocol>HTTPS</Protocol>
          <Port>443</Port>
          <HealthCheckPort/>
        </ServicePort>
        <ServicePort>
          <Protocol>TCP</Protocol>
          <Port/>
          <HealthCheckPort/>
        </ServicePort>
      </Member>
      <Operational>false</Operational>
    </Pool>
    <VirtualServer>
      <IsEnabled>true</IsEnabled>
      <Name>VDC-1</Name>
      <Interface type="application/vnd.vmware.vcloud.orgVdcNetwork+xml" name="VDC-1" href="http://interface.vdc-1/19237"/>
      <IpAddress>20.1.0.2</IpAddress>
      <ServiceProfile>
        <IsEnabled>true</IsEnabled>
        <Protocol>HTTP</Protocol>
        <Port>80</Port>
        <Persistence>
          <Method/>
        </Persistence>
      </ServiceProfile>
      <ServiceProfile>
        <IsEnabled>true</IsEnabled>
        <Protocol>HTTPS</Protocol>
        <Port>443</Port>
        <Persistence>
          <Method/>
        </Persistence>
      </ServiceProfile>
      <ServiceProfile>
        <IsEnabled>false</IsEnabled>
        <Protocol>TCP</Protocol>
        <Port/>
        <Persistence>
          <Method/>
        </Persistence>
      </ServiceProfile>
      <Logging>false</Logging>
      <Pool>Frontend pool</Pool>
    </VirtualServer>
  </LoadBalancerService>
</EdgeGatewayServiceConfiguration>
}
end

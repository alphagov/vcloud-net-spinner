require 'spec_helper'
require 'vcloud_network_configurator/vcloud_settings'

describe VcloudSettings do

  it "should return session url" do
    settings = VcloudSettings.new({:url => 'www.abra.ka.dabra/api',
                                   :edge_gateway_uuid => 'sad-123g-12eda-12enas'})
    settings.sessions_url.should == 'www.abra.ka.dabra/api/sessions'
  end

  it "should return edge_gateway_config_url" do
    settings = VcloudSettings.new({:url => 'www.abra.ka.dabra/api',
                                   :edge_gateway_uuid => 'sad-123g-12eda-12enas'})

    settings.edge_gateway_config_url.should == 'www.abra.ka.dabra/api/admin/edgeGateway/sad-123g-12eda-12enas/action/configureServices'
  end

end

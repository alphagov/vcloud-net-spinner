require 'spec_helper'
require 'vcloud_network_configurator'

describe "happy path" do

  before :each do
    WebMock.disable_net_connect!
    WebMock.reset!

    session_url = "https://super%40gds-preview:man@www.vcloud.eggplant.com/sessions"

    stub_request(:post, session_url).
      with(:headers => {'Accept'=>'application/*+xml;version=5.1', 'User-Agent'=>'Ruby'}).
      to_return(:status => 401)
  end

  it "should abort on failure of authorization" do
    args = ["-u", "super", "-p", "man", "-U", "123321", "-d",
            "spec/integration/test_data/rules_dir", "-e", "preview",
            "-c", "firewall", "https://www.vcloud.eggplant.com"]

    configurator = VcloudNetworkConfigurator.new(args)
    expect { configurator.execute }.to raise_error(SystemExit, "Could not authenticate user")
  end

end

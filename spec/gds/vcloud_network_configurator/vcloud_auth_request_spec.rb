require 'spec_helper'
require 'gds/vcloud_network_configurator/vcloud_auth_request'

module Gds
  describe VcloudAuthRequest do

    context "submit an auth request" do
      before :each do
        stub_request(:post, "https://super:man@www.foo.bar/sessions").
          with(:headers => { 'Accept' => 'application/*+xml;version=5.1' })
      end

      it "should return response received" do
        vcloud_url = VcloudUrl.new({ :url => "https://www.foo.bar" })
        request = VcloudAuthRequest.new vcloud_url, "super", "man"

        request.submit.code.should == "200"
      end
    end
  end
end

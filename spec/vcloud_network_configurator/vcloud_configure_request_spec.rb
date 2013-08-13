require 'spec_helper'

describe 'VcloudConfigureRequest' do
  describe "#initialize" do
    it "should initialize without error out if files it requires are not present" do
      expect {
        request = VcloudConfigureRequest.new mock(:edge_gateway_config_url => true),
        'auth-header', 'env', 'firewall', './this-is-no-path' }.to_not raise_error
    end
  end

  describe "#submit" do
    it "should not submit http request when no xml generated" do
      Component::Firewall.reset
      Net::HTTP.should_not_receive(:new)

      request = VcloudConfigureRequest.new mock(:edge_gateway_config_url => true),
        'auth-header', 'env', 'firewall', './this-is-no-path'
      expect { request.submit }.to raise_error(SystemExit, "No rules found. exiting")
    end
  end
end

require 'spec_helper'

describe 'VcloudConfigureRequest' do
  describe "#initialize" do
    it "should initialize without error out if files it requires are not present" do
      expect {
        request = VcloudConfigureRequest.new mock(:edge_gateway_config_url => true),
        'auth-header', 'env', 'firewall', './this-is-no-path' }.to_not raise_error
    end
  end
end

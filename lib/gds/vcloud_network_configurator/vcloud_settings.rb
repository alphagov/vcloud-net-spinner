module Gds
  class VcloudSettings

    def initialize options = {}
      @api_url = options[:url]
      @edge_gateway_uuid = options[:edge_gateway_uuid]
    end

    def sessions_url
      @api_url + "/sessions"
    end

    def edge_gateway_config_url
      @api_url + "/api/admin/edgeGateway/" + @edge_gateway_uuid + "/action/configureServices"
    end
  end
end

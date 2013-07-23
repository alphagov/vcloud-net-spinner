require "net/http"
require "gds/vcloud_network_configurator/vcloud_url"

module Gds
  class VcloudAuthRequest

    def initialize vcloud_url, username, password
      @user_name = username
      @password = password
      @vcloud_url = vcloud_url
    end

    def submit
      puts "Submitting auth request at #{@vcloud_url.sessions_url}\n"
      url = URI(@vcloud_url.sessions_url)
      request = Net::HTTP::Post.new url.request_uri
      request['Accept'] = 'application/*+xml;version=5.1'
      request.basic_auth @user_name, @password
      session = Net::HTTP.new(url.host, url.port)
      session.use_ssl = true

      response = session.start do |http|
        http.request request
      end

      puts "HTTP #{response.code}"
      puts response
      return response
    end
  end
end

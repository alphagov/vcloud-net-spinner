require "net/http"
require "vcloud_network_configurator/vcloud_settings"

class VcloudAuthRequest

  def initialize vcloud_settings, username, password
    @user_name = username
    @password = password
    @vcloud_settings = vcloud_settings
    @response = nil
  end

  def submit
    puts "Submitting auth request at #{@vcloud_settings.sessions_url}\n"
    url = URI(@vcloud_settings.sessions_url)
    request = Net::HTTP::Post.new url.request_uri
    request['Accept'] = VcloudSettings.request_headers['Accept']
    request.basic_auth @user_name, @password
    session = Net::HTTP.new(url.host, url.port)
    session.use_ssl = true

    response = session.start do |http|
      http.request request
    end

    puts "HTTP #{response.code}"
    puts response
    @response = response
  end

  def authenticated?
    auth_response.code == "200"
  end

  def auth_response
    @response
  end

end

require "net/http"

class VcloudCheckForConfigureTaskRequest

  def initialize auth_header, task_url
    @auth_header = auth_header
    @task_url = task_url
  end

  def submit
    url = URI(@task_url)
    request = Net::HTTP::Get.new url.request_uri
    request['Accept'] = 'application/*+xml;version=5.1'
    request['x-vcloud-authorization'] = @auth_header

    puts "Submitting request at #{@task_url}"

    session = Net::HTTP.new(url.host, url.port)
    session.use_ssl = true
    response = session.start do |http|
      http.request request
    end
    puts response
    return response
  end
end

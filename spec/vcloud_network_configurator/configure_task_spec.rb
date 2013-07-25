require 'spec_helper'
require 'vcloud_network_configurator/configure_task'

describe ConfigureTask do

  describe "#url" do
    it "should extract url from xml" do
      ConfigureTask.new(fixture_xml).url.
        should == "https://vendor-api-url.net/task/123321"
    end
  end

  describe "#complete?" do
    it "should return false id status not success" do
      ConfigureTask.new(fixture_xml).should_not be_complete
    end

    it "should return false id status not success" do
      success_xml = fixture_xml.gsub("status=\"running\"", "status=\"success\"")
      ConfigureTask.new(success_xml).should be_complete
    end
  end

  describe "#error?" do
    it "should error out if error code provided" do
      error_xml = fixture_xml.gsub("</Task>",
                              "<Error majorErrorCode=\"Bazinga\"></Task>")
      ConfigureTask.new(error_xml).should be_error
    end

  end

end

def fixture_xml
  %q{
<?xml version="1.0" encoding="UTF-8"?>
<Task xmlns="http://www.vmware.com/vcloud/v1.5" status="running"
  startTime="2013-07-19T14:46:52.943+01:00"
  serviceNamespace="com.vmware.vcloud"
  operationName="networkConfigureEdgeGatewayServices"
  operation="Updating services EdgeGateway GDS Development Gateway"
  expiryTime="2013-10-17T14:46:52.943+01:00" cancelRequested="false" name="task"
  id="urn:vcloud:task:0e38b845-92fb-47e7-bc89-1fa29547f487"
  type="application/vnd.vmware.vcloud.task+xml"
  href="https://vendor-api-url.net/task/123321"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.vmware.com/vcloud/v1.5 http://vendor-api-url.net/v1.5/schema/master.xsd">
    <Link rel="task:cancel"
      href="https://vendor-api-url.net/task/123321/action/cancel"/>
    <User type="application/vnd.vmware.admin.user+xml" name="gsingh"
      href="https://vendor-api-url.net/admin/user/2020202"/>
    <Organization type="application/vnd.vmware.vcloud.org+xml"
      name="GDS-Development"
      href="https://vendor-api-url.net/org/9999999"/>
    <Progress>0</Progress>
    <Details/>
</Task>}
end

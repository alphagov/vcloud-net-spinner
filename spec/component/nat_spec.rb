require 'spec_helper'
require 'nokogiri'
require 'equivalent-xml'
require 'component/nat'

describe "nat" do

  it "should be able to generate XML that matches what we created directly through the control panel" do
    nat do
      snat :interface => "TestData", :original => { :ip => "172.10.0.0/8" }, :translated => { :ip => "200.11.99.70" }, :id => 65538
      dnat :interface => "TestData", :original => { :ip => "200.11.99.70", :port => 22 }, :translated => { :ip => "172.10.0.100", :port => 22 }, :id => 65539
      dnat :interface => "TestData", :original => { :ip => "200.11.99.72", :port => 443 }, :translated => { :ip => "172.16.0.2", :port => 443 }, :id => 65540
      dnat :interface => "TestData", :original => { :ip => "200.11.99.70", :port => 80 }, :translated => { :ip => "172.10.0.3", :port => 80 }, :id => 65537
      dnat :interface => "TestData", :original => { :ip => "200.11.99.70", :port => 1022 }, :translated => { :ip => "172.10.0.200", :port => 22 }, :id => 65542
      dnat :interface => "TestData", :original => { :ip => "200.11.99.74", :port => 443 }, :translated => { :ip => "172.16.0.2", :port => 443 }, :id => 65543
      dnat :interface => "TestData", :original => { :ip => "200.11.99.75", :port => 80 }, :translated => { :ip => "172.10.0.20", :port => 80 }, :id => 65544
      dnat :interface => "TestData", :original => { :ip => "200.11.99.76", :port => 80 }, :translated => { :ip => "172.10.0.21", :port => 80 }, :id => 65545
      dnat :interface => "TestData", :original => { :ip => "200.11.99.75", :port => 443 }, :translated => { :ip => "172.16.0.2", :port => 443 }, :id => 65546
      dnat :interface => "TestData", :original => { :ip => "200.11.99.76", :port => 443 }, :translated => { :ip => "172.16.0.2", :port => 443 }, :id => 65547
      dnat :interface => "TestData", :original => { :ip => "200.11.99.70", :port => 443 }, :translated => { :ip => "172.16.5.0", :port => 443 }, :id => 65548
    end

    interfaces = {
      "TestData" => "https://vendor-api-url.net/admin/network/1000"
    }
    Nokogiri::XML(Component::NAT.generate_xml(interfaces).doc.root.to_s).should be_equivalent_to Nokogiri::XML(File.open("spec/component/nat.xml"))
  end
end

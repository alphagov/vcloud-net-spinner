require 'spec_helper'
require 'nokogiri'
require 'equivalent-xml'
require 'firewall'
#require 'edgegateway/production/interfaces'

describe "firewall" do
  it "should be able to generate XML that matches what we created directly through the control panel" do
    Firewall.reset
    firewall do
      rule "Oubound Traffic", :protocols => [:tcp, :udp] do
         source      :ip => "Any",           :port => "Any"
         destination :ip => "external",      :port => "Any"
      end

      rule "ssh access to jumpbox1",           :protocols => [:tcp] do
         source      :ip => "Any",           :port => "Any"
         destination :ip => "200.11.99.70", :port => 22
      end
    end

    Nokogiri::XML(Firewall.generate_xml.doc.root.to_s).should be_equivalent_to Nokogiri::XML(File.open("spec/firewall.xml"))
  end

  it "should default the protocol to tcp" do
    Firewall.reset
    firewall do
      rule "tcp only" do
         source      :ip => "Any", :port => "Any"
         destination :ip => "Any", :port => "Any"
      end
    end

    expected = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.EdgeGatewayServiceConfiguration('xmlns' => "http://www.vmware.com/vcloud/v1.5", 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance", 'xsi:schemaLocation' => "http://www.vmware.com/vcloud/v1.5 http://vendor-api-url.net/v1.5/schema/master.xsd") {
        xml.FirewallService {
          xml.IsEnabled "true"
          xml.DefaultAction "drop"
          xml.LogDefaultAction "false"

          xml.FirewallRule {
            xml.Id "1"
            xml.IsEnabled "true"
            xml.MatchOnTranslate "false"
            xml.Description "tcp only"
            xml.Policy "allow"

            xml.Protocols {
              xml.Tcp "true"
            }

            xml.Port "-1"
            xml.DestinationPortRange "Any"
            xml.DestinationIp "Any"
            xml.SourcePort "-1"
            xml.SourcePortRange "Any"
            xml.SourceIp "Any"
            xml.EnableLogging "false"
        }
      }
    }
    end

    Nokogiri::XML(Firewall.generate_xml.doc.root.to_s).should be_equivalent_to (expected.doc.root.to_s)
  end

  it "should default the source to Any" do
    Firewall.reset
    firewall do
      rule "source port any" do
         source      :ip => "Any"
         destination :ip => "Any", :port => "Any"
      end
    end

    expected = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.EdgeGatewayServiceConfiguration('xmlns' => "http://www.vmware.com/vcloud/v1.5", 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance", 'xsi:schemaLocation' => "http://www.vmware.com/vcloud/v1.5 http://vendor-api-url.net/v1.5/schema/master.xsd") {
        xml.FirewallService {
          xml.IsEnabled "true"
          xml.DefaultAction "drop"
          xml.LogDefaultAction "false"

          xml.FirewallRule {
            xml.Id "1"
            xml.IsEnabled "true"
            xml.MatchOnTranslate "false"
            xml.Description "source port any"
            xml.Policy "allow"

            xml.Protocols {
              xml.Tcp "true"
            }

            xml.Port "-1"
            xml.DestinationPortRange "Any"
            xml.DestinationIp "Any"
            xml.SourcePort "-1"
            xml.SourcePortRange "Any"
            xml.SourceIp "Any"
            xml.EnableLogging "false"
        }
      }
    }
    end

    Nokogiri::XML(Firewall.generate_xml.doc.root.to_s).should be_equivalent_to (expected.doc.root.to_s)
  end
end

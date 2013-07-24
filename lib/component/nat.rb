require 'rubygems'
require 'nokogiri'

module Component
  class NAT
    attr_reader :rules

    def initialize
      @rules = []
      @count = 65537
    end

    def dnat(options)
      rule(options.merge(:type => 'DNAT'))
    end

    def snat(options)
      rule(options.merge(:type => 'SNAT'))
    end

    def rule(options)
      @count += 1;
      defaults = { :enabled => true, :protocol => 'tcp', :id=>@count}
      options = defaults.merge(options)
      rules << options
    end

    def self.instance
      @nat ||= NAT.new
    end

    def self.generate_xml
      Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.EdgeGatewayServiceConfiguration('xmlns' => "http://www.vmware.com/vcloud/v1.5", 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance", 'xsi:schemaLocation' => "http://www.vmware.com/vcloud/v1.5 http://vendor-api-url.net/v1.5/schema/master.xsd") {
          xml.NatService {
            xml.IsEnabled "true"

            NAT.instance.rules.each do |rule|
              xml.NatRule {
                xml.RuleType rule[:type]
                xml.IsEnabled rule[:enabled]
                xml.Id rule[:id]
                xml.GatewayNatRule {
                  xml.Interface('type' => "application/vnd.vmware.admin.network+xml", 'name' => rule[:interface], 'href' => interfaces[rule[:interface]])
                  xml.OriginalIp rule[:original][:ip]

                  if rule[:original][:port]
                    xml.OriginalPort rule[:original][:port]
                  end

                  xml.TranslatedIp rule[:translated][:ip]

                  if rule[:translated][:port]
                    xml.TranslatedPort rule[:translated][:port]
                  end

                  if rule[:type] == "DNAT"
                    xml.Protocol rule[:protocol]
                  end

                }
              }
            end
          }
        }
      end
    end
  end
end

def nat (&block)
  Component::NAT.instance.instance_eval(&block)
end

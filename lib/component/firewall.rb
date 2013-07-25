require 'rubygems'
require 'nokogiri'

module Component
  class Firewall
    attr_reader :rules

    def initialize
      @rules = []
      @count = 0
    end

    def rule(description, options = {}, &block)
      defaults = { :enabled => true, :protocols => [:tcp], :id => @count+=1, :description => description}
      @current_rule = defaults.merge(options)
      rules << @current_rule
      yield
    ensure
      @current_rule = nil
    end

    def source(options)
      @current_rule[:source] = { :port => options[:port] || "Any", :ip => options[:ip] }
    end

    def destination(options)
      @current_rule[:destination] = { :port => options[:port], :ip => options[:ip] }
    end

    def self.reset
      @firewall = nil
    end

    def self.instance
      @firewall ||= Firewall.new
    end

    def self.generate_xml interfaces
      Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.EdgeGatewayServiceConfiguration('xmlns' => "http://www.vmware.com/vcloud/v1.5", 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance", 'xsi:schemaLocation' => "http://www.vmware.com/vcloud/v1.5 http://vendor-api-url.net/v1.5/schema/master.xsd") {
          xml.FirewallService {
            xml.IsEnabled "true"
            xml.DefaultAction "drop"
            xml.LogDefaultAction "false"

            Firewall.instance.rules.each do |rule|
              xml.FirewallRule {
                xml.Id rule[:id]
                xml.IsEnabled rule[:enabled]
                xml.MatchOnTranslate "false"
                xml.Description rule[:description]
                xml.Policy "allow"

                xml.Protocols {
                  rule[:protocols].each do |protocol|
                    xml.send(protocol.to_s.capitalize, true)
                  end
                }

                if rule[:protocols].first == :icmp
                  xml.IcmpSubType "any"
                end

                xml.Port rule[:destination][:port] == "Any" ? "-1" : rule[:destination][:port]
                xml.DestinationPortRange rule[:destination][:port]
                xml.DestinationIp rule[:destination][:ip]
                xml.SourcePort rule[:source][:port] == "Any" ? "-1" : rule[:source][:port]
                xml.SourcePortRange rule[:source][:port]
                xml.SourceIp rule[:source][:ip]
                xml.EnableLogging "false"
              }
            end
          }
        }
      end
    end
  end
end

def firewall (&block)
  Component::Firewall.instance.instance_eval(&block)
end

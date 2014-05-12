require 'rubygems'
require 'nokogiri'

module Component
  class LoadBalancer
    attr_reader :pools, :configurations

    def initialize
      @pools = []
      @configurations = []
    end

    def configure(name, &block)
      @current_configuration = { :name => name, :virtual_servers => [], :pool => nil }
      @configurations << @current_configuration
      yield
    ensure
      @current_pool = nil
    end

    def virtual_server(options = {})
      raise "Can't add a virtual server without first having defined a pool" if @current_pool.nil?
      virtual_server = { :name => options[:name], :pool => @current_pool[:name], :ip => options[:ip], :interface => options[:interface] }
      @current_configuration[:virtual_servers] << virtual_server
    end

    def pool(nodes, &block)
      @current_pool = { :name => "#{@current_configuration[:name]} pool", :ports => [], :nodes => nodes }
      @current_configuration[:pool] = @current_pool
      @pools << @current_pool
      yield
    end

    def http(options = {})
      defaults = { :enabled => true, :health_check_path => "/", :port => 80, :health_check_mode => "HTTP" }
      options = defaults.merge(options)
      @current_pool[:ports] << { :port => options[:port], :health_check_port => options[:health_check_port],
                                 :health_check_path => options[:health_check_path], :enabled => options[:enabled],
                                 :type => :http, :health_check_mode=>options[:health_check_mode] }
    end

    def https(options = {})
      raise "VMWare does not support health check URI for SSL" unless options[:health_check_path].nil?
      defaults = { :enabled => true, :health_check_path => "", :port => 443, :health_check_mode => "SSL" }
      options = defaults.merge(options)
      @current_pool[:ports] << { :port => options[:port], :health_check_port => options[:health_check_port], # Health check path (URI) not supported for SSL
                                 :enabled => options[:enabled], :type => :https,
                                 :health_check_mode => options[:health_check_mode] }
    end

    def load_balances(port, options = {})
      defaults = { :enabled => true, :health_check_path => "/" }
      options = defaults.merge(options)
      @current_pool[:ports] << { :port => port, :health_check_port => options[:health_check_port], :health_check_path => options[:health_check_path],
                                 :enabled => options[:enabled], :type => options[:type] }
    end

    def self.instance
      @lb ||= LoadBalancer.new
    end

    def self.generate_xml interfaces
      return if LoadBalancer.instance.pools.nil? or LoadBalancer.instance.pools.empty?
      Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.EdgeGatewayServiceConfiguration('xmlns' => "http://www.vmware.com/vcloud/v1.5", 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance", 'xsi:schemaLocation' => "http://www.vmware.com/vcloud/v1.5 http://vendor-api-url.net/v1.5/schema/master.xsd") {
          xml.LoadBalancerService {
            xml.IsEnabled 'false'
            LoadBalancer.instance.pools.each do |pool|
              xml.Pool {
                xml.Name pool[:name]

                pool[:ports].each do |port|
                  xml.ServicePort {
                    xml.IsEnabled port[:enabled]
                    xml.Protocol port[:port] == 443 ? "HTTPS" : "HTTP"
                    xml.Algorithm 'ROUND_ROBIN'
                    xml.Port port[:port]

                    if port[:health_check_port]
                      xml.HealthCheckPort port[:health_check_port]
                    else
                      xml.HealthCheckPort
                    end

                    xml.HealthCheck {
                      xml.Mode port[:health_check_mode]
                      xml.Uri port[:health_check_path]
                      xml.HealthThreshold "2"
                      xml.UnhealthThreshold "3"
                      xml.Interval "5"
                      xml.Timeout	"15"
                    }
                  }
                end

                xml.ServicePort {
                  xml.IsEnabled 'false'
                  xml.Protocol "TCP"
                  xml.Algorithm 'ROUND_ROBIN'
                  xml.Port
                  xml.HealthCheckPort
                  xml.HealthCheck {
                    xml.Mode "TCP"
                    xml.HealthThreshold "2"
                    xml.UnhealthThreshold "3"
                    xml.Interval "5"
                    xml.Timeout	"15"
                  }
                }

                pool[:nodes].each do |node|
                  xml.Member {
                    xml.IpAddress node
                    xml.Weight "1"

                    ["HTTP", "HTTPS"].each do |protocol|
                      xml.ServicePort {
                        xml.Protocol protocol
                        xml.Port pool[:ports].find { |port| port[:type] == protocol.downcase.to_sym }[:port]
                        xml.HealthCheckPort
                      }
                    end

                    xml.ServicePort {
                      xml.Protocol "TCP"
                      xml.Port
                      xml.HealthCheckPort
                    }

                  }
                end
                xml.Operational "false"
              }
            end

            LoadBalancer.instance.configurations.each do |configuration|
              configuration[:virtual_servers].each do |virtual_server|
                xml.VirtualServer {
                  xml.IsEnabled "true"
                  xml.Name virtual_server[:name]
                  xml.Interface('type' => "application/vnd.vmware.vcloud.orgVdcNetwork+xml", :name => virtual_server[:interface], :href => interfaces[virtual_server[:interface]])
                  xml.IpAddress virtual_server[:ip]

                  configuration[:pool][:ports].each do |port|
                    xml.ServiceProfile {
                      xml.IsEnabled port[:enabled]
                      xml.Protocol port[:type].to_s.upcase
                      xml.Port port[:port]
                      xml.Persistence {
                        if port[:type] == :https
                          xml.Method
                        else
                          xml.Method
                        end
                      }
                    }
                  end

                  xml.ServiceProfile {
                    xml.IsEnabled "false"
                    xml.Protocol "TCP"
                    xml.Port
                    xml.Persistence {
                      xml.Method
                    }
                  }
                  xml.Logging "false"
                  xml.Pool configuration[:pool][:name]

                }
              end
            end
          }
        }
      end
    end

  end
end

def load_balancer (&block)
  Component::LoadBalancer.instance.instance_eval(&block)
end

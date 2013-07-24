require 'spec_helper'
require 'nokogiri'
require 'equivalent-xml'
require 'load_balancer'


describe "load balancer" do
  it "should be able to generate XML that matches what we created directly through the control panel" do
    load_balancer do
      configure "Signonotron" do
        pool ["172.16.0.2", "172.16.0.3"] do
          http :enabled => false
          https :health_check_port => 9401
        end

        virtual_server :name => "Signonotron public", :interface => "TestData", :ip => "200.11.99.71"
        virtual_server :name => "Signonotron internal", :interface => "TestData", :ip => "172.16.1.1"
      end

      configure "Search" do
        pool ["172.12.0.2", "172.12.0.3", "172.12.0.4"] do
          http :health_check_port => 9509
          https :health_check_port => 9409
        end

        virtual_server :name => "Search internal", :interface => "TestData", :ip => "172.12.1.3"
      end

      configure "Static" do
        pool ["172.12.0.2", "172.12.0.3", "172.12.0.4"] do
          http :health_check_port => 9513
          https :health_check_port => 9413
        end

        virtual_server :name => "Static internal", :interface => "TestData", :ip => "172.12.1.2"
      end

      configure "Frontend" do
        pool ["172.12.0.2", "172.12.0.3", "172.12.0.4"] do
          http :health_check_port => 9505
          https :health_check_port => 9405
        end

        virtual_server :name => "Frontend internal", :interface => "TestData", :ip => "172.12.1.4"
      end

      configure "Smartanswers" do
        pool ["172.12.0.2", "172.12.0.3", "172.12.0.4"] do
            http :health_check_port => 9510
            https :health_check_port => 9410
        end

        virtual_server :name => "Smartanswers internal", :interface => "TestData", :ip => "172.12.1.5"
      end

      configure "Router" do
        pool ["172.11.0.2", "172.11.0.3", "172.11.0.4"] do
            http
            https
        end

        virtual_server :name => "Router public", :interface => "TestData", :ip => "200.11.99.73"
      end

      configure "Calendars" do
        pool ["172.12.0.2", "172.12.0.3", "172.12.0.4"] do
            http :health_check_port => 9511
            https :health_check_port => 9411
        end

        virtual_server :name => "Calendars internal", :interface => "TestData", :ip => "172.12.1.1"
      end

      configure "router-internal" do
        pool ["172.11.0.2", "172.11.0.3", "172.11.0.4"] do
            http :port => 8080, :health_check_path => "/router/management/status"
            https :enabled => false
        end

        virtual_server :name => "Router internal", :interface => "TestData", :ip => "172.11.1.1"
      end

      configure "EFG" do
        pool ["172.14.0.2"] do
            http :health_check_port => 9519
            https :health_check_port => 9419
        end

        virtual_server :name => "EFG public", :interface => "TestData", :ip => "200.11.99.77"
      end
    end

    Nokogiri::XML(LoadBalancer.generate_xml.doc.root.to_s).should be_equivalent_to Nokogiri::XML(File.open("spec/lb.xml"))
  end

  it "should blow up if pool is not defined before virtual server" do
    expect  { load_balancer do
      configure "Signonotron" do
        virtual_server :name => "Signonotron public", :interface => "TestData", :ip => "200.11.99.71"
        virtual_server :name => "Signonotron internal", :interface => "TestData", :ip => "172.16.1.1"
      end
    end }.to raise_error
  end
end


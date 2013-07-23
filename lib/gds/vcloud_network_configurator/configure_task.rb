require 'nokogiri'
module Gds
  class ConfigureTask
    def initialize configure_xml
      @configure_xml =  Nokogiri::XML(configure_xml)
      @configure_xml.remove_namespaces!
    end

    def url
      @configure_xml.xpath("//Task/@href").to_s
    end

    def complete?
      @configure_xml.xpath("//Task/@status").to_s == "success"
    end

    def error?
      puts @configure_xml.xpath("//Task/Error/@majorErrorCode")

      !@configure_xml.xpath("//Task/Error/@majorErrorCode").empty?
    end
  end
end

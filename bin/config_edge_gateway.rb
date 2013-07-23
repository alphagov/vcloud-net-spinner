#!/usr/bin/env ruby
$:.unshift File.dirname(__FILE__) + '/../lib'
#$:.unshift File.dirname(__FILE__) + '/../edgegateway'
require 'gds/vcloud_network_configurator'

Gds::VcloudNetworkConfigurator.new(ARGV).execute

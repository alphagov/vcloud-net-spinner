#!/usr/bin/env ruby
$:.unshift File.dirname(__FILE__) + '/../lib'
#$:.unshift File.dirname(__FILE__) + '/../edgegateway'
require 'vcloud_network_configurator'

VcloudNetworkConfigurator.new(ARGV).execute

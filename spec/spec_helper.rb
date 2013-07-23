specdir=File.dirname(__FILE__)
$:.unshift File.join(specdir, '../lib')
$:.unshift File.join(specdir, '..')

require 'webmock/rspec'
require 'rspec'


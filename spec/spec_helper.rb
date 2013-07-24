specdir=File.dirname(__FILE__)
$:.unshift File.join(specdir, '../lib')
$:.unshift File.join(specdir, '..')

require 'webmock/rspec'
require 'rspec'

def interfaces
  @interfaces ||= {
    "TestData" => "https://vendor-api-url.net/admin/network/1000"
  }
end

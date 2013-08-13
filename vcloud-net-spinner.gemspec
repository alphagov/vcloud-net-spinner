# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vcloud_network_configurator/version"

Gem::Specification.new do |s|
  s.name        = "vcloud-net-spinner"
  s.version     = VERSION
  s.authors     = ["Garima Singh"]
  s.email       = ["igarimasingh@gmail.com"]
  s.homepage    = "https://github.com/alphagov/vcloud-net-spinner"
  s.summary     = %q{Configure firewall, NAT and load balancer for vcloud}
  s.description = "It allows one to right rules for firewall, NAT and load " +
    "balancer using vcloud API and configure them on the vendor end"

  s.rubyforge_project = "vcloud-net-spinner"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "mocha"
  s.add_development_dependency "webmock"
  s.add_development_dependency "rspec", "~> 2.11.0"
  s.add_development_dependency "equivalent-xml", "~> 0.2.9"
  s.add_development_dependency "gem_publisher", "~> 1.3.0"
  s.add_runtime_dependency "parallel"
  s.add_runtime_dependency "highline"
  s.add_runtime_dependency "nokogiri", "~> 1.5.0"
end


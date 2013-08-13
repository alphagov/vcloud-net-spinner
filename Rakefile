require "bundler/gem_tasks"
require 'rake/testtask'
require 'rspec/core/rake_task'
require "gem_publisher"

RSpec::Core::RakeTask.new(:spec) do |task|
  task.pattern = FileList.new('spec/**/*_spec.rb') do |file|
    file.exclude(/integration/)
  end
  task.rspec_opts = ['--color']
end

RSpec::Core::RakeTask.new(:integration) do |task|
  task.pattern = FileList['spec/integration/*_spec.rb']
  task.rspec_opts = ['--color']
end

task :default => [:spec]

desc "Publish gem to RubyGems.org"
task :publish_gem do |t|
  gem = GemPublisher.publish_if_updated("vcloud-net-spinner.gemspec", :rubygems)
  puts "Published #{gem}" if gem
end


require "bundler/gem_tasks"
require 'rake/testtask'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.pattern = FileList.new('spec/**/*_spec.rb') do |file|
    file.exclude(/integration/)
  end
end

RSpec::Core::RakeTask.new(:integration) do |task|
  task.pattern = FileList['spec/integration/*_spec.rb']
end

task :default => :spec


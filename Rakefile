#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = '-Ispec'
end

require 'coveralls/rake/task'
Coveralls::RakeTask.new
task :spec_with_coveralls => [:spec, 'coveralls:push']

require "bundler/gem_tasks"
require "rake/testtask"
require 'rake/clean'

CLEAN.include '*.gem'

Rake::TestTask.new :spec do |t|
  t.libs << "spec"
  t.test_files = FileList['spec/*_spec.rb']
  t.verbose = true
end

task :default => :spec

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

namespace :docs do
  desc "Run local server for docs"
  task :server do
    puts "starting doc server on http://localhost:4567"
    `cd docs && bundle exec middleman server`
  end

  desc "publish docs to gh-pages"
  task :publish do
    `cd docs && bundle exec rake publish`
  end
end

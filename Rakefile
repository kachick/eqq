# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rake/testtask'
require 'rspec/core/rake_task'

begin
  require 'rubocop/rake_task'
rescue LoadError
  puts 'can not use rubocop in this environment'
else
  RuboCop::RakeTask.new
end

task default: [:test_behaviors]

desc 'Test behaviors, this should be passed'
task test_behaviors: [:test, :spec]

desc 'Simulate CI results in local machine as possible'
multitask simulate_ci: [:test_behaviors, :validate_signatures, :rubocop, :check_non_ruby]

Rake::TestTask.new(:test) do |tt|
  tt.pattern = 'test/**/test_*.rb'
  tt.warning = true
  tt.verbose = false
end

RSpec::Core::RakeTask.new(:spec) do |rt|
  rt.ruby_opts = %w[-w]
  rt.verbose = false
end

desc 'Validate signatures, this should be passed'
multitask validate_signatures: [:'signature:validate_yard']

namespace :signature do
  desc 'Generate YARD docs for the syntax check'
  task :validate_yard do
    sh "bundle exec yard --fail-on-warning #{'--no-progress' if ENV['CI']}"
  end
end

desc 'Prevent miss packaging!'
task :view_packaging_files do
  sh 'rm -rf ./pkg'
  sh 'rake build'
  cd 'pkg' do
    sh 'gem unpack *.gem'
    sh 'tree -I *\.gem'
  end
  sh 'rm -rf ./pkg'
end

desc 'Print dependencies'
task :deps do
  sh 'ruby --version'
  sh 'dprint --version'
  sh 'typos --version'
end

desc 'Tests except ruby'
task :check_non_ruby do
  sh 'dprint check'
  sh 'typos . .github .vscode'
end

# encoding: UTF-8
# frozen_string_literal: true


require 'bundler/gem_tasks'

require 'yard'

require 'rake/clean'
require 'rake/testtask'

require 'ssc.bot/version'

CLEAN.exclude('{.git,stock}/**/*')
CLOBBER.include('doc/')

task default: [:test]

desc 'Generate documentation'
task :doc => [:yard] do |task|
end

Rake::TestTask.new() do |task|
  task.libs = ['lib','test']
  task.pattern = File.join('test','**','*_test.rb')
  task.description += ": '#{task.pattern}'"
  task.verbose = false
  task.warning = true
end

YARD::Rake::YardocTask.new() do |task|
  #task.options.push('--template-path',File.join('yard','templates'))
  task.options.push('--title',"SSC.Bot v#{SSCBot::VERSION} Doc")
end

# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Bot.
# Copyright (c) 2020 Jonathan Bradley Whited (@esotericpig)
# 
# SSC.Bot is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# SSC.Bot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with SSC.Bot.  If not, see <https://www.gnu.org/licenses/>.
#++


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

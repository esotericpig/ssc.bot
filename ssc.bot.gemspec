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


lib = File.expand_path(File.join('..','lib'),__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'ssc.bot/version'


Gem::Specification.new() do |spec|
  spec.name        = 'ssc.bot'
  spec.version     = SSCBot::VERSION
  spec.authors     = ['Jonathan Bradley Whited (@esotericpig)']
  spec.email       = ['bradley@esotericpig.com']
  spec.licenses    = ['LGPL-3.0-or-later']
  spec.homepage    = 'https://github.com/esotericpig/ssc.bot'
  spec.summary     = 'Simple Subspace Continuum Bot library.'
  spec.description = spec.summary
  
  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/esotericpig/ssc.bot/issues',
    'changelog_uri'   => 'https://github.com/esotericpig/ssc.bot/blob/master/CHANGELOG.md',
    'homepage_uri'    => 'https://github.com/esotericpig/ssc.bot',
    'source_code_uri' => 'https://github.com/esotericpig/ssc.bot',
  }
  
  spec.require_paths = ['lib']
  spec.bindir        = 'bin'
  
  spec.files = [
    Dir.glob(File.join("{#{spec.require_paths.join(',')}}",'**','*.{erb,rb}')),
    Dir.glob(File.join(spec.bindir,'*')),
    Dir.glob(File.join('{test,yard}','**','*.{erb,rb}')),
    %W( Gemfile #{spec.name}.gemspec Rakefile ),
    %w( CHANGELOG.md LICENSE.txt README.md ),
  ].flatten()
  
  spec.required_ruby_version = '>= 2.4'
  
  spec.add_runtime_dependency 'attr_bool','~> 0.1'   # attr_accessor?/reader?
  
  spec.add_development_dependency 'bundler'   ,'~> 2.1'
  spec.add_development_dependency 'minitest'  ,'~> 5.14'
  spec.add_development_dependency 'rake'      ,'~> 13.0'
  spec.add_development_dependency 'rdoc'      ,'~> 6.2'   # YARDoc RDoc (*.rb)
  spec.add_development_dependency 'redcarpet' ,'~> 3.5'   # YARDoc Markdown (*.md)
  spec.add_development_dependency 'yard'      ,'~> 0.9'   # Documentation
  spec.add_development_dependency 'yard_ghurt','~> 1.2'   # YARDoc GitHub Rake tasks
end

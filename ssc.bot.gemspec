# encoding: UTF-8
# frozen_string_literal: true


require_relative 'lib/ssc.bot/version'

Gem::Specification.new do |spec|
  spec.name        = 'ssc.bot'
  spec.version     = SSCBot::VERSION
  spec.authors     = ['Bradley Whited']
  spec.email       = ['code@esotericpig.com']
  spec.licenses    = ['LGPL-3.0-or-later']
  spec.homepage    = 'https://github.com/esotericpig/ssc.bot'
  spec.summary     = 'Simple Subspace Continuum Bot library.'
  spec.description = spec.summary

  spec.metadata = {
    'homepage_uri'    => 'https://github.com/esotericpig/ssc.bot',
    'source_code_uri' => 'https://github.com/esotericpig/ssc.bot',
    'bug_tracker_uri' => 'https://github.com/esotericpig/ssc.bot/issues',
    'changelog_uri'   => 'https://github.com/esotericpig/ssc.bot/blob/master/CHANGELOG.md',
  }

  spec.required_ruby_version = '>= 2.5'
  spec.require_paths         = ['lib']
  spec.bindir                = 'bin'

  spec.files = [
    Dir.glob(File.join("{#{spec.require_paths.join(',')}}",'**','*.{erb,rb}')),
    Dir.glob(File.join(spec.bindir,'*')),
    Dir.glob(File.join('{test,yard}','**','*.{erb,rb}')),
    %W[ Gemfile #{spec.name}.gemspec Rakefile .yardopts ],
    %w[ CHANGELOG.md LICENSE.txt README.md ],
  ].flatten

  spec.add_runtime_dependency 'attr_bool','~> 0.2'   # attr_accessor?/reader?

  spec.add_development_dependency 'bundler'   ,'~> 2.2'
  spec.add_development_dependency 'minitest'  ,'~> 5.14'
  spec.add_development_dependency 'rake'      ,'~> 13.0'
  spec.add_development_dependency 'rdoc'      ,'~> 6.3'   # YARDoc RDoc (*.rb)
  spec.add_development_dependency 'redcarpet' ,'~> 3.5'   # YARDoc Markdown (*.md)
  spec.add_development_dependency 'yard'      ,'~> 0.9'   # Doc
  spec.add_development_dependency 'yard_ghurt','~> 1.2'   # YARDoc GitHub Rake tasks
end

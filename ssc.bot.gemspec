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
    'rubygems_mfa_required' => 'true',
    'homepage_uri'          => 'https://github.com/esotericpig/ssc.bot',
    'source_code_uri'       => 'https://github.com/esotericpig/ssc.bot',
    'bug_tracker_uri'       => 'https://github.com/esotericpig/ssc.bot/issues',
    'changelog_uri'         => 'https://github.com/esotericpig/ssc.bot/blob/main/CHANGELOG.md',
  }

  spec.required_ruby_version = '>= 2.5'
  spec.require_paths         = ['lib']
  spec.bindir                = 'bin'

  spec.files = [
    Dir.glob("{#{spec.require_paths.join(',')}}/**/*.{erb,rb}"),
    Dir.glob("#{spec.bindir}/*"),
    Dir.glob('{spec,test,yard}/**/*.{erb,rb}'),
    %W[Gemfile #{spec.name}.gemspec Rakefile .yardopts],
    %w[CHANGELOG.md LICENSE.txt README.md],
  ].flatten

  spec.add_dependency 'attr_bool','~> 0.2' # attr_accessor?/reader?
end

# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Bot.
# Copyright (c) 2020-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


require 'rbconfig'

module SSCBot
  ###
  # Your typical utility methods that
  # should be moved into a separate Gem one day...
  #
  # @author Jonathan Bradley Whited
  # @since  0.1.0
  ###
  module Util
    def self.os(host_os=RbConfig::CONFIG['host_os'])
      os = :unknown

      case host_os
      when /darwin/i
        os = :macos
      # I think 'cygwin' here makes sense.
      when /linux|arch|cygwin/i
        os = :linux
      else
        # Here so that 'win' doesn't capture 'darwin'.
        case host_os
        # windows|mswin|bccwin|wince
        when /win|mingw|emx/i
          os = :windows
        end
      end

      return os
    end
    OS = os

    def self.quote_str_or_regex(value)
      if value.respond_to?(:source)
        return value.source.gsub(' ','\\ ') # For //x
      else
        return Regexp.quote(value)
      end
    end

    def self.ruby_engine
      engines = [
        defined?(::RUBY_ENGINE) ? ::RUBY_ENGINE : nil,
        RbConfig::CONFIG['ruby_install_name'],
        RbConfig::CONFIG['rubyw_install_name'],
        RbConfig::CONFIG['RUBY_INSTALL_NAME'],
        RbConfig::CONFIG['RUBYW_INSTALL_NAME'],
        RbConfig.ruby,
      ].join('|').downcase

      if engines.include?('jruby')
        return :jruby
      elsif engines.include?('truffleruby')
        return :truffleruby
      end

      return :ruby
    end
    RUBY_ENGINE = ruby_engine

    # Universally, is +str+ empty after stripping or +nil+?
    def self.u_blank?(str)
      return str.nil? || str.empty? || u_strip(str).empty?
    end

    # Universally, left strip +str+'s leading (head) space.
    def self.u_lstrip(str)
      return nil if str.nil?
      return str.gsub(/\A[[:space:]]+/,'')
    end

    # Universally, right strip +str+'s trailing (tail) space.
    def self.u_rstrip(str)
      return nil if str.nil?
      return str.gsub(/[[:space:]]+\z/,'')
    end

    # Universally, strip +str+'s space.
    def self.u_strip(str)
      return nil if str.nil?
      return str.gsub(/\A[[:space:]]+|[[:space:]]+\z/,'')
    end
  end
end

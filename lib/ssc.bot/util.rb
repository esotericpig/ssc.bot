#!/usr/bin/env ruby
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


module SSCBot
  ###
  # Your typical utility methods that
  # should be moved into a separate Gem one day...
  # 
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  module Util
    def self.quote_str_or_regex(value)
      if value.respond_to?(:source)
        return value.source.gsub(' ','\\ ') # For //x
      else
        return Regexp.quote(value)
      end
    end
    
    # Universally, is +str+ empty after stripping or +nil+?
    def self.u_blank?(str)
      return str.nil?() || strip(str).empty?()
    end
    
    # Universally, left strip +str+'s leading (head) space.
    def self.u_lstrip(str)
      return nil if str.nil?()
      return str.gsub(/\A[[:space:]]+/,'')
    end
    
    # Universally, right strip +str+'s trailing (tail) space.
    def self.u_rstrip(str)
      return nil if str.nil?()
      return str.gsub(/[[:space:]]+\z/,'')
    end
    
    # Universally, strip +str+'s space.
    def self.u_strip(str)
      return nil if str.nil?()
      return str.gsub(/\A[[:space:]]+|[[:space:]]+\z/,'')
    end
  end
end

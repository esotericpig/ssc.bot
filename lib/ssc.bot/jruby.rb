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


begin
  require 'java'
rescue LoadError => e
  raise e.exception('Must use JRuby for Java-related files')
end

require 'ssc.bot/user/jrobot_message_sender'

module SSCBot
  ###
  # Require this file to include all JRuby (Java-related) files.
  # Must be using JRuby.
  #   require 'ssc.bot/jruby'
  # 
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.2
  ###
  module JRuby
  end
end
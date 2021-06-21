# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Bot.
# Copyright (c) 2020-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
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
  # @author Jonathan Bradley Whited
  # @since  0.1.2
  ###
  module JRuby
  end
end

# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Bot.
# Copyright (c) 2020-2021 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'forwardable'

require 'ssc.bot/chat_log/message_parser'

module SSCBot
class ChatLog
  ###
  # @author Bradley Whited
  # @since  0.1.0
  ###
  module MessageParsable
    extend Forwardable

    MAX_NAMELEN = MessageParser::MAX_NAMELEN

    attr_reader :parser

    (MessageParser.public_instance_methods - Class.public_instance_methods).each do |method|
      name = method.to_s

      next if name.start_with?('match_','parse_')

      def_delegator(:@parser,method)
    end
  end
end
end

# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Bot.
# Copyright (c) 2020-2021 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


require 'ssc.bot/ssc_file'

require 'ssc.bot/chat_log/message'
require 'ssc.bot/chat_log/message_parsable'
require 'ssc.bot/chat_log/message_parser'
require 'ssc.bot/chat_log/messages'

module SSCBot
  ###
  # @author Bradley Whited
  # @since  0.1.0
  ###
  class ChatLogFile < SSCFile
    include ChatLog::MessageParsable

    def initialize(filename,mode=DEFAULT_MODE,parser: ChatLog::MessageParser.new,**file_kargs)
      super(filename,mode,**file_kargs)

      @parser = parser
    end

    def parse_line
      line = read_uline

      return line.nil? ? nil : parse(line)
    end
  end
end

# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Bot.
# Copyright (c) 2020-2021 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'forwardable'

require 'ssc.bot/chat_log'
require 'ssc.bot/user'

module SSCBot
  ###
  # Chat Log + User
  #
  # @author Bradley Whited
  # @since  0.1.2
  ###
  class Clu
    include Forwardable

    attr_reader :bots
    attr_reader :chat_log
    attr_reader :msg_sender

    def initialize(chat_log,msg_sender)
      super()

      @bots = {}
      @chat_log = chat_log
      @msg_sender = msg_sender

      def_delegators(:@bots,:[])
      def_delegator(:@bots,:key?,:bot?)
      def_delegators(:@chat_log,*(@chat_log.public_methods - public_methods))
      def_delegators(:@msg_sender,*(@msg_sender.public_methods - public_methods))
    end

    def add_bot(bot_class)
      bot = @bots[bot_class]

      if bot.nil?
        bot = bot_class.new(self)
        @bots[bot_class] = bot
      end

      return bot
    end
  end
end

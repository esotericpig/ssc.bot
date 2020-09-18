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


require 'forwardable'

require 'ssc.bot/chat_log'
require 'ssc.bot/user'


module SSCBot
  ###
  # Chat Log + User
  # 
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.2
  ###
  class Clu
    attr_reader :bots
    attr_reader :chat_log
    attr_reader :msg_sender
    
    def initialize(chat_log,msg_sender)
      extend Forwardable
      
      super()
      
      @bots = {}
      @chat_log = chat_log
      @msg_sender = msg_sender
      
      def_delegators(:@chat_log,*(@chat_log.public_methods - public_methods))
      def_delegators(:@msg_sender,*(@msg_sender.public_methods - public_methods))
    end
    
    def add_bot(bot_class)
      cluid = bot_class.const_get(:CLUID)
      bot = @bots[cluid]
      
      if bot.nil?()
        bot = bot_class.new(self)
        @bots[cluid] = bot
      end
      
      return bot
    end
  end
end

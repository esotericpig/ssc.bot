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

require 'ssc.bot/chat_log/message_parser'

module SSCBot
class ChatLog
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  module MessageParsable
    extend Forwardable
    
    MAX_NAMELEN = MessageParser::MAX_NAMELEN
    
    def_delegators(:@parser,
      :autoset_namelen?,:autoset_namelen=,
      :check_history_count,:check_history_count=,
      :commands,
      :messages,
      :namelen,:namelen=,
      :regex_cache,
      :store_history?,:store_history=,
      :strict?,:strict=,
      
      :parse,
      
      :clear_history,
      :reset_namelen,
      :store_command,
      
      :command?,
    )
    
    attr_reader :parser
  end
end
end

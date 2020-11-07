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

module SSCBot; class ChatLog
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  module MessageParsable
    extend Forwardable
    
    MAX_NAMELEN = MessageParser::MAX_NAMELEN
    
    attr_reader :parser
    
    (MessageParser.public_instance_methods - Class.public_instance_methods).each() do |method|
      name = method.to_s()
      
      next if name.start_with?('match_') || name.start_with?('parse_')
      
      def_delegator(:@parser,method)
    end
  end
end; end

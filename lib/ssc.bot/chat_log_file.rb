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


require 'ssc.bot/ssc_file'

require 'ssc.bot/chat_log/message'
require 'ssc.bot/chat_log/message_parsable'
require 'ssc.bot/chat_log/message_parser'
require 'ssc.bot/chat_log/messages'

module SSCBot
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class ChatLogFile < SSCFile
    include ChatLog::MessageParsable
    
    def initialize(filename,mode=DEFAULT_MODE,parser: ChatLog::MessageParser.new(),**file_kargs)
      super(filename,mode,**file_kargs)
      
      @parser = parser
    end
    
    def parse_line()
      line = get_line()
      
      return line.nil?() ? nil : parse(line)
    end
  end
end

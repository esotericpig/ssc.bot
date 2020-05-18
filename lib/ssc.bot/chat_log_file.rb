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
require 'set'

require 'ssc.bot/ssc_file'

require 'ssc.bot/chat_log/message_parser'


module SSCBot
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class ChatLogFile < SSCFile
    extend Forwardable
    
    MAX_NAMELEN = ChatLog::MessageParser::MAX_NAMELEN
    PARSER_PARAMS = Set[:namelen,:strict]
    
    def_delegators :@parser,:namelen,:namelen=,:parse,:regex_cache,:strict?,:strict=
    
    attr_reader :parser
    
    def initialize(filename,mode=DEFAULT_MODE,**kargs)
      file_args = kargs.reject() {|k,v| PARSER_PARAMS.include?(k) }
      parser_args = kargs.slice(*PARSER_PARAMS)
      
      super(filename,mode,**file_args)
      
      @parser = ChatLog::MessageParser.new(**parser_args)
    end
    
    def parse_line()
      line = get_line()
      
      return nil if line.nil?()
      
      return parse(line)
    end
  end
end

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


require 'set'


module SSCBot
class ChatLog
  ###
  # The base class of all parsed messages from a chat log file.
  # 
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class Message
    # Valid types of messages.
    # 
    # You can add your own custom type(s) that you parse manually:
    #   SSCBot::ChatLog::Message::TYPES.add(:custom)
    TYPES = Set[
      # In order of F1 Help box.
      *%i{
        pub team private remote freq squad chat
        ?lines ?namelen ?ignore ?nopubchat ?obscene ?away ?log ?logbuffer
          ?kill kill ?enter enter ?leave leave ?message ?messages ?chat
        ?status ?scorereset ?team ?spec ?target ?time ?flags ?score ?crown
          ?best ?buy
        ?owner ?password ?usage ?userid ?find ?ping ?packetloss ?lag ?music
          ?sound ?alarm ?sheep ?getnews
        ?squadowner ?squad ?squadlist ?loadmacro ?savemacro
        unknown
      },
    ]
    
    attr_reader :line # @return [String] the raw (unparsed) line from the file
    attr_reader :type # @return [Symbol] what type of message this is; one of {TYPES}
    
    # @param line [String] the raw (unparsed) line from the file
    # @param type [Symbol] what type of message this is; must be one of {TYPES}
    def initialize(line,type: :unknown)
      type = type.to_sym()
      
      raise ArgumentError,"invalid line{#{line}}" if line.nil?()
      raise ArgumentError,"invalid type{#{type}}" if !valid_type?(type)
      
      @line = line
      @type = type
    end
    
    # @param  type [Symbol] the type to check if valid
    # @return [Boolean] +true+ if +type+ is one of {TYPES}, else +false+
    def self.valid_type?(type)
      return TYPES.include?(type)
    end
    
    # A convenience method for comparing anything that responds to
    # +:to_sym():+, like +String+.
    # 
    # @param  type [String,Symbol] the type to convert & compare against
    # @return [Boolean] +true+ if this message is of type +type+, else +false+
    def type?(type)
      return @type == type.to_sym()
    end
  end
end
end

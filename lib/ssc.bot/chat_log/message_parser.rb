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


require 'attr_bool'

require 'ssc.bot/error'
require 'ssc.bot/util'
require 'ssc.bot/chat_log/message'
require 'ssc.bot/chat_log/messages'


module SSCBot
class ChatLog
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class MessageParser
    MAX_NAMELEN = 24
    
    attr_accessor :namelen
    attr_accessor? :strict
    
    def initialize(namelen: nil,strict: true)
      @namelen = namelen
      @strict = strict
    end
    
    def parse(line)
      if line.nil?()
        if @strict
          raise ArgumentError,"invalid line{#{line}}"
        else
          line = ''
        end
      end
      
      message = nil
      
      if !line.empty?()
        case line[0]
        when 'C'
          message = parse_chat(line)
        when 'E'
          message = parse_freq(line)
        when 'P'
          if remote?(line)
            message = parse_remote(line)
          else
            message = parse_private(line)
          end
        when 'T'
          message = parse_team(line)
        else
          if pub?(line)
            message = parse_pub(line)
          else
            case line
            # '  Name(100) killed by: Name'
            when /\A  .*[[:alnum:]]+\(\d+\) killed by: .*[[:alnum:]]+.*\z/
              #message = parse_kill(line)
            # '  Message Name Length: 24'
            when /\A  Message Name Length: \d+\z/
              #message = parse_q_namelen(line)
            end
          end
        end
      end
      
      if message.nil?()
        message = Message.new(line,type: :unknown)
      end
      
      return message
    end
    
    # @example Format
    #   # NOT affected by namelen.
    #   'C 1:Name> Message'
    def parse_chat(line)
      player = parse_player(line,type: :chat)
      
      return nil if player.nil?()
      
      channel = line.match(/\AC (\d+)\:/)
      name_i = player.name.match(/\A\d+\:/)
      
      if channel.nil?() || name_i.nil?()
        if @strict
          raise ParseError,"no chat channel for chat message{#{line}}"
        else
          return nil
        end
      end
      
      channel = channel[1].to_i()
      name_i = name_i[0].length
      name = player.name[name_i..-1]
      
      if name.nil?() || name.empty?()
        if @strict
          raise ParseError,"no player name for chat message{#{line}}"
        else
          return nil
        end
      end
      
      return ChatMessage.new(line,channel: channel,name: name,message: player.message)
    end
    
    # @example Format
    #   'E Name> Message'
    def parse_freq(line)
      player = parse_player(line,type: :freq)
      
      return nil if player.nil?()
      
      return FreqMessage.new(line,name: player.name,message: player.message)
    end
    
    # @example Format
    #   'X Name> Message'
    def parse_player(line,type:)
      # 2+ for 'X '; MAX+2 for '> '.
      message_i = 2 + (@namelen.nil?() ? (MAX_NAMELEN + 2) : @namelen)
      name = line[2...message_i]
      
      if name.nil?() || name.empty?()
        if @strict
          raise ParseError,"no player name for #{type} message{#{line}}"
        else
          return nil
        end
      end
      
      if @namelen.nil?()
        # index() instead of rindex() in case of 'X Name> QuotedName> QuotedMessage'.
        message_i = name.index('> ')
        
        # 0 = '> Message' (no name).
        if message_i.nil?() || message_i == 0
          if @strict
            raise ParseError,"no player name for #{type} message{#{line}}"
          else
            return nil
          end
        end
        
        name = name[0...message_i]
        message_i += 2 # For 'X '
      end
      
      name = Util.u_lstrip(name)
      
      if name.empty?()
        if @strict
          raise ParseError,"blank player name for #{type} message{#{line}}"
        else
          return nil
        end
      end
      
      message = line[message_i + 2..-1] # +2 for '> '
      
      if message.nil?()
        if @strict
          raise ParseError,"invalid player message for #{type} message{#{line}}"
        else
          return nil
        end
      end
      
      return PlayerMessage.new(line,type: type,name: name,message: message)
    end
    
    # @example Format
    #   'P Name> Message'
    def parse_private(line)
      player = parse_player(line,type: :private)
      
      return nil if player.nil?()
      
      return PrivateMessage.new(line,name: player.name,message: player.message)
    end
    
    # @example Format
    #   '  Name> Message'
    def parse_pub(line)
      player = parse_player(line,type: :pub)
      
      return nil if player.nil?()
      
      return PubMessage.new(line,name: player.name,message: player.message)
    end
    
    # @example Format
    #   # NOT affected by namelen.
    #   'P :SelfName:Message'
    #   'P (Name)>Message'
    def parse_remote(line)
      # 5+ for 'P ' and (':...:' or '(...)>').
      message_i = 5 + MAX_NAMELEN
      name = line[2...message_i]
      
      if name.nil?() || name.empty?()
        if @strict
          raise ParseError,"no player name for remote private message{#{line}}"
        else
          return nil
        end
      end
      
      own = (name[0] == ':')
      name = name[1..-1] # '' if length == 1
      
      # index() instead of rindex() in case of 'P (Name)>(QuotedName)>QuotedMessage'.
      message_i = name.index(own ? ':' : ')>')
      
      # 0 = (':: Message' or '()> Message') (no name).
      if message_i.nil?() || message_i == 0
        if @strict
          raise ParseError,"no player name for remote private message{#{line}}"
        else
          return nil
        end
      end
      
      name = name[0...message_i]
      message_i += (own ? 1 : 2) # +1 for ':' or +2 for ')>'
      message = [message_i..-1]
      
      if message.nil?()
        if @strict
          raise ParseError,"invalid player message for remote private message{#{line}}"
        else
          return nil
        end
      end
      
      return RemoteMessage.new(line,own: own,name: name,message: message)
    end
    
    # @example Format
    #   'T Name> Message'
    def parse_team(line)
      player = parse_player(line,type: :team)
      
      return nil if player.nil?()
      
      return TeamMessage.new(line,name: player.name,message: player.message)
    end
    
    # @example Format
    #   '  Name> Message'
    def pub?(line)
      return false if line !~ /\A  .*[[:alnum:]]+\> /
      
      # 4+ for leading spaces '  ' and '> '.
      message_i = 4 + (@namelen.nil?() ? MAX_NAMELEN : @namelen)
      name = line[2...message_i]
      
      return !name.nil?() && name =~ /\A.*[[:alnum:]]+\> /
    end
    
    # @example Format
    #   # NOT affected by namelen.
    #   'P :SelfName:Message'
    #   'P (Name)>Message'
    def remote?(line)
      # 5+ for 'P ' and (':...:' or '(...)>').
      message_i = 5 + MAX_NAMELEN
      name = line[2...message_i]
      
      return !name.nil?() && (
        name =~ /\A\:([[:alnum:]]+|[[:alnum:]]+.*[[:alnum:]]+)\:/ ||
        name =~ /\A\(([[:alnum:]]+|[[:alnum:]]+.*[[:alnum:]]+)\)\>/
      )
    end
  end
end
end

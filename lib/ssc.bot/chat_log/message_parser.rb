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
    
    def match_player(line,name_prefix: %r{},name_suffix: %r{\>\s},type: %r{..},use_namelen: true)
      if use_namelen && !@namelen.nil?()
        match = line.match(/
          \A#{type.source}
          #{name_prefix.source}(?<name>.{#{@namelen}})#{name_suffix.source}
          (?<message>.*)\z
        /x)
      else
        match = line.match(/
          \A#{type}
          #{name_prefix.source}(?<name>.*?\S)#{name_suffix.source}
          (?<message>.*)\z
        /x)
      end
      
      return match
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
          if (match = remote?(line))
            message = parse_remote(line,match: match)
          else
            message = parse_private(line)
          end
        when 'T'
          message = parse_team(line)
        else
          if (match = pub?(line))
            message = parse_pub(line,match: match)
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
      match = match_player(line,name_prefix: %r{(?<channel>\d+)\:})
      player = parse_player(line,type: :chat,match: match)
      
      return nil if player.nil?()
      
      channel = match[:channel]
      
      if channel.nil?()
        if @strict
          raise ParseError,"invalid chat channel for chat message{#{line}}"
        else
          return nil
        end
      end
      
      channel = channel.to_i()
      
      return ChatMessage.new(line,channel: channel,name: player.name,message: player.message)
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
    def parse_player(line,type:,match: nil)
      match = match_player(line) if match.nil?()
      
      if match.nil?()
        if @strict
          raise ParseError,"invalid #{type} message{#{line}}"
        else
          return nil
        end
      end
      
      name = Util.u_lstrip(match[:name])
      message = match[:message]
      
      if name.nil?() || name.empty?() || name.length > MAX_NAMELEN
        if @strict
          raise ParseError,"invalid player name for #{type} message{#{line}}"
        else
          return nil
        end
      end
      
      if message.nil?()
        if @strict
          raise ParseError,"invalid player message for #{type} message{#{line}}"
        else
          return nil
        end
      end
      
      return PlayerMessage.new(line,type: :unknown,name: name,message: message)
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
    def parse_pub(line,match: nil)
      player = parse_player(line,type: :pub,match: match)
      
      return nil if player.nil?()
      
      return PubMessage.new(line,name: player.name,message: player.message)
    end
    
    # @example Format
    #   # NOT affected by namelen.
    #   'P :SelfName:Message'
    #   'P (Name)>Message'
    def parse_remote(line,match:)
      player = parse_player(line,type: 'remote private',match: match)
      
      return nil if player.nil?()
      
      own = (line[2] == ':')
      
      return RemoteMessage.new(line,own: own,name: player.name,message: player.message)
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
      match = match_player(line,type: %r{\s\s})
      
      if !match.nil?()
        name = Util.u_lstrip(match[:name])
        
        if name.nil?() || name.empty?() || name.length > MAX_NAMELEN || match[:message].nil?()
          return false
        end
      end
      
      return match
    end
    
    # @example Format
    #   # NOT affected by namelen.
    #   'P :SelfName:Message'
    #   'P (Name)>Message'
    def remote?(line)
      match = match_player(line,name_prefix: %r{\:},name_suffix: %r{\:},use_namelen: false)
      
      if match.nil?()
        match = match_player(line,name_prefix: %r{\(},name_suffix: %r{\)\>},use_namelen: false)
      end
      
      return match
    end
  end
end
end

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
    attr_reader :regex_cache
    attr_accessor? :strict
    
    def initialize(namelen: nil,strict: true)
      @namelen = namelen
      @regex_cache = {}
      @strict = strict
    end
    
    # The interpreter should cache the args' default values,
    # so no reason to manually cache them unless a variable is involved inside.
    # 
    # Do not pass spaces +' '+ into the args, must use +\s+ instead.
    def match_player(line,type_name:,name_prefix: %r{},name_suffix: %r{\>\s},type_prefix: %r{..},use_namelen: true)
      cached_regex = @regex_cache[type_name]
      
      if cached_regex.nil?()
        cached_regex = {}
        @regex_cache[type_name] = cached_regex
      end
      
      if use_namelen && !@namelen.nil?()
        regex = cached_regex[@namelen]
        
        if regex.nil?()
          # Be careful to not use spaces ' ', but to use '\s' instead
          # because of the '/x' option.
          regex = /
            \A#{type_prefix.source}
            #{name_prefix.source}(?<name>.{#{@namelen}})#{name_suffix.source}
            (?<message>.*)\z
          /x
          
          cached_regex[@namelen] = regex
        end
      else
        regex = cached_regex[:no_namelen]
        
        if regex.nil?()
          # Be careful to not use spaces ' ', but to use '\s' instead
          # because of the '/x' option.
          regex = /
            \A#{type_prefix.source}
            #{name_prefix.source}(?<name>.*?\S)#{name_suffix.source}
            (?<message>.*)\z
          /x
          
          cached_regex[:no_namelen] = regex
        end
      end
      
      return regex.match(line)
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
          # Check this one first to prevent abuse from pubbers.
          if (match = pub?(line))
            message = parse_pub(line,match: match)
          else
            if (match = kill?(line))
              message = parse_kill(line,match: match)
            elsif (match = q_namelen?(line))
              message = parse_q_namelen(line,match: match)
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
      match = match_player(line,type_name: :chat,name_prefix: %r{(?<channel>\d+)\:},use_namelen: false)
      player = parse_player(line,type_name: :chat,match: match)
      
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
      player = parse_player(line,type_name: :freq)
      
      return nil if player.nil?()
      
      return FreqMessage.new(line,name: player.name,message: player.message)
    end
    
    # @example Format
    #   '  Killed.Name(100) killed by: Killer.Name'
    def parse_kill(line,match:)
      if match.nil?()
        if @strict
          raise ParseError,"invalid kill message{#{line}}"
        else
          return nil
        end
      end
      
      killed = match[:killed]
      bounty = match[:bounty]
      killer = match[:killer]
      
      if killed.nil?()
        if @strict
          raise ParseError,"invalid killed name for kill message{#{line}}"
        else
          return nil
        end
      end
      
      if bounty.nil?()
        if @strict
          raise ParseError,"invalid bounty for kill message{#{line}}"
        else
          return nil
        end
      end
      
      if killer.nil?()
        if @strict
          raise ParseError,"invalid killer name for kill message{#{line}}"
        else
          return nil
        end
      end
      
      bounty = bounty.to_i()
      
      return KillMessage.new(line,killed: killed,bounty: bounty,killer: killer)
    end
    
    # @example Format
    #   'X Name> Message'
    def parse_player(line,type_name:,match: nil)
      match = match_player(line,type_name: :player) if match.nil?()
      
      if match.nil?()
        if @strict
          raise ParseError,"invalid #{type_name} message{#{line}}"
        else
          return nil
        end
      end
      
      name = Util.u_lstrip(match[:name])
      message = match[:message]
      
      if name.nil?() || name.empty?() || name.length > MAX_NAMELEN
        if @strict
          raise ParseError,"invalid player name for #{type_name} message{#{line}}"
        else
          return nil
        end
      end
      
      if message.nil?()
        if @strict
          raise ParseError,"invalid player message for #{type_name} message{#{line}}"
        else
          return nil
        end
      end
      
      return PlayerMessage.new(line,type: :unknown,name: name,message: message)
    end
    
    # @example Format
    #   'P Name> Message'
    def parse_private(line)
      player = parse_player(line,type_name: :private)
      
      return nil if player.nil?()
      
      return PrivateMessage.new(line,name: player.name,message: player.message)
    end
    
    # @example Format
    #   '  Name> Message'
    def parse_pub(line,match: nil)
      player = parse_player(line,type_name: :pub,match: match)
      
      return nil if player.nil?()
      
      return PubMessage.new(line,name: player.name,message: player.message)
    end
    
    # @example Format
    #   '  Message Name Length: 24'
    def parse_q_namelen(line,match:)
      if match.nil?()
        if @strict
          raise ParseError,"invalid ?namelen message{#{line}}"
        else
          return nil
        end
      end
      
      namelen = match[:namelen]
      namelen = namelen.to_i() # nil is 0
      
      if namelen < 1
        if @strict
          raise ParseError,"invalid namelen for ?namelen message{#{line}}"
        else
          return nil
        end
      end
      
      return QNamelenMessage.new(line,namelen: namelen)
    end
    
    # @example Format
    #   # NOT affected by namelen.
    #   'P :Self.Name:Message'
    #   'P (Name)>Message'
    def parse_remote(line,match:)
      player = parse_player(line,type_name: 'remote private',match: match)
      
      return nil if player.nil?()
      
      own = (line[2] == ':')
      
      return RemoteMessage.new(line,own: own,name: player.name,message: player.message)
    end
    
    # @example Format
    #   'T Name> Message'
    def parse_team(line)
      player = parse_player(line,type_name: :team)
      
      return nil if player.nil?()
      
      return TeamMessage.new(line,name: player.name,message: player.message)
    end
    
    # @example Format
    #   '  Killed.Name(100) killed by: Killer.Name'
    def kill?(line)
      return /\A  (?<killed>.*?\S)\((?<bounty>\d+)\) killed by: (?<killer>.*?\S)\z/.match(line)
    end
    
    # @example Format
    #   '  Name> Message'
    def pub?(line)
      match = match_player(line,type_name: :pub,type_prefix: %r{\s\s})
      
      if !match.nil?()
        name = Util.u_lstrip(match[:name])
        
        if name.nil?() || name.empty?() || name.length > MAX_NAMELEN || match[:message].nil?()
          return false
        end
      end
      
      return match
    end
    
    # @example Format
    #   '  Message Name Length: 24'
    def q_namelen?(line)
      return /\A  Message Name Length: (?<namelen>\d+)\z/.match(line)
    end
    
    # @example Format
    #   # NOT affected by namelen.
    #   'P :Self.Name:Message'
    #   'P (Name)>Message'
    def remote?(line)
      match = match_player(line,type_name: :'remote.out',
        name_prefix: %r{\:},name_suffix: %r{\:},use_namelen: false)
      
      if match.nil?()
        match = match_player(line,type_name: :'remote.in',
          name_prefix: %r{\(},name_suffix: %r{\)\>},use_namelen: false)
      end
      
      return match
    end
  end
end
end

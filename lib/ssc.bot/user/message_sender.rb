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
require 'time'

require 'ssc.bot/error'
require 'ssc.bot/util'

module SSCBot
module User
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class MessageSender
    extend AttrBool::Ext
    
    DEFAULT_ESCAPE_STR = '.'
    DEFAULT_FLOOD_COUNT = 8
    DEFAULT_FLOOD_MIN_SLEEP = 0.001
    DEFAULT_FLOOD_SECS = 6
    
    # Message Macros
    # - In order of F1 Help box.
    MM_TICKNAME = '%tickname'
    MM_SELFNAME = '%selfname'
    MM_SQUAD = '%squad'
    MM_FREQ = '%freq'
    MM_BOUNTY = '%bounty'
    MM_FLAGS = '%flags'
    MM_ENERGY = '%energy'
    MM_KILLER = '%killer'
    MM_KILLED = '%killed'
    MM_COORD = '%coord'
    MM_AREA = '%area'
    MM_RED = '%red'
    MM_REDNAME = '%redname'
    MM_REDBOUNTY = '%redbounty'
    MM_REDFLAGS = '%redflags'
    
    constants.each() do |constant|
      name = constant.to_s()
      
      next unless name.start_with?('MM_')
      
      define_method(name.downcase().to_sym()) do
        return self.class.const_get(constant)
      end
    end
    
    attr_accessor? :escape_percent
    attr_accessor? :escape_space
    attr_accessor :escape_str
    attr_accessor :flood_count
    attr_accessor :flood_min_sleep
    attr_accessor :flood_secs
    attr_reader :message_count
    attr_reader :message_time
    attr_accessor? :staff
    
    def put(message)
      raise AbstractMethodError,__method__
    end
    
    def send_message()
      raise AbstractMethodError,__method__
    end
    
    def type(message)
      raise AbstractMethodError,__method__
    end
    
    def initialize(escape_percent: false,escape_space: true,escape_str: DEFAULT_ESCAPE_STR,flood_count: DEFAULT_FLOOD_COUNT,flood_min_sleep: DEFAULT_FLOOD_MIN_SLEEP,flood_secs: DEFAULT_FLOOD_SECS,staff: false)
      super()
      
      @escape_percent = escape_percent
      @escape_space = escape_space
      @escape_str = escape_str
      @flood_count = flood_count
      @flood_min_sleep = flood_min_sleep
      @flood_secs = flood_secs
      @message_count = 0
      @message_time = Time.now()
      @staff = staff
    end
    
    def escape_pub(message,escape_percent: @escape_percent,escape_space: @escape_space,escape_str: @escape_str,staff: @staff)
      if escape_percent
        message = message.gsub('%','%%')
      end
      
      escape = false
      
      case message[0]
      when '#'
        escape = true
      else
        if escape_space && message[0] =~ /[[:space:]]/
          escape = true
        else
          stripped_message = Util.u_lstrip(message)
          
          case stripped_message[0]
          when ':'
            if stripped_message.index(':',1)
              escape = true
            end
          when '/',%q{'},'"',';','='
            escape = true
          when '?'
            if stripped_message[1] =~ /[[:alpha:]]/
              escape = true
            end
          when '*','-'
            escape = true if staff
          end
        end
      end
      
      if escape
        message = "#{escape_str}#{message}"
      end
      
      return message
    end
    
    def prevent_flood()
      @message_count += 1
      
      if @message_count >= @flood_count
        diff_time = Time.now() - @message_time
        
        if diff_time <= @flood_secs
          sleep_secs = (@flood_secs - diff_time).round(4) + 0.001
          sleep_secs = @flood_min_sleep if sleep_secs < @flood_min_sleep
        else
          sleep_secs = @flood_min_sleep
        end
        
        sleep(sleep_secs)
        
        @message_count = 0
      end
      
      @message_time = Time.now()
    end
    
    def put_or_type(message)
      put(message)
    end
    
    def send(message)
      put(message)
      send_message()
    end
    
    def send_or_types(message)
      send(message)
    end
    
    def send_or_types_safe(message)
      send_or_types(message)
      prevent_flood()
    end
    
    def send_safe(message)
      send(message)
      prevent_flood()
    end
    
    def types(message)
      type(message)
      send_message()
    end
    
    def types_safe(message)
      types(message)
      prevent_flood()
    end
    
    def send_chat(message)
      send_safe(";#{message}")
    end
    
    def send_chat_to(channel,message)
      send_safe(";#{channel};#{message}")
    end
    
    def send_freq(message)
      send_safe(%Q{"#{message}})
    end
    
    def send_freq_eq(freq)
      send_safe("=#{freq}")
    end
    
    def send_private(message)
      send_safe("/#{message}")
    end
    
    def send_private_to(name,message)
      send_safe(":#{name}:#{message}")
    end
    
    def send_private_to_last(message,last=1)
      put_or_type('::')
      
      while (last -= 1) > 0
        put_or_type(':')
      end
      
      send_safe(message)
    end
    
    def send_pub(message,**kargs)
      send_safe(escape_pub(message,**kargs))
    end
    
    def send_q_chat()
      send_safe('?chat')
    end
    
    def send_q_chat_eq(*names)
      send_safe("?chat=#{names.join(',')}")
    end
    
    def send_q_enter()
      send_safe('?enter')
    end
    
    def send_q_find(player)
      send_safe("?find #{player}")
    end
    
    def send_q_kill()
      send_safe('?kill')
    end
    
    def send_q_leave()
      send_safe('?leave')
    end
    
    def send_q_loadmacro(filename)
      send_safe("?loadmacro #{filename}")
    end
    
    def send_q_log()
      send_safe('?log')
    end
    
    def send_q_log_to(filename)
      send_safe("?log #{filename}")
    end
    
    def send_q_logbuffer()
      send_safe('?logbuffer')
    end
    
    def send_q_logbuffer_to(filename)
      send_safe("?logbuffer #{filename}")
    end
    
    def send_q_namelen()
      send_safe('?namelen')
    end
    
    def send_q_namelen_eq(namelen)
      send_safe("?namelen=#{namelen}")
    end
    
    def send_q_lines()
      send_safe('?lines')
    end
    
    def send_q_lines_eq(lines)
      send_safe("?lines=#{lines}")
    end
    
    def send_q_savemacro(filename)
      send_safe("?savemacro #{filename}")
    end
    
    def send_q_spec()
      send_safe('?spec')
    end
    
    def send_q_team()
      send_safe('?team')
    end
    
    def send_squad(message)
      send_safe("##{message}")
    end
    
    def send_squad_to(squad,message)
      send_safe(":##{squad}:#{message}")
    end
    
    def send_team(message)
      send_safe("//#{message}")
    end
    
    def send_team2(message)
      send_safe("'#{message}")
    end
  end
end
end

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


require 'time'

require 'ssc.bot/error'


module SSCBot
module User
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class MessageSender
    DEFAULT_FLOOD_COUNT = 8
    DEFAULT_FLOOD_SLEEP = 6
    DEFAULT_FLOOD_SLEEP_MIN = 0.001
    DEFAULT_FLOOD_TIME = 6
    
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
    
    attr_accessor :flood_count
    attr_accessor :flood_time
    attr_accessor :message_count
    
    def put_message(text)
      raise AbstractMethodError
    end
    
    def puts_message(text)
      raise AbstractMethodError
    end
    
    def type_message(text)
      raise AbstractMethodError
    end
    
    def types_message(text)
      raise AbstractMethodError
    end
    
    def initialize(flood_count: DEFAULT_FLOOD_COUNT,flood_sleep: DEFAULT_FLOOD_SLEEP,flood_sleep_min: DEFAULT_FLOOD_SLEEP_MIN,flood_time: DEFAULT_FLOOD_TIME)
      super()
      
      @flood_count = flood_count
      @flood_sleep = flood_sleep
      @flood_sleep_min = flood_sleep_min
      @flood_time = flood_time
      @message_count = 0
      @message_time = Time.now()
    end
    
    def prevent_flood()
      @message_count += 1
      
      if @message_count >= @flood_count
        diff_time = Time.now() - @message_time
        
        if diff_time <= @flood_time
          sleep_time = (@flood_sleep - diff_time).round(4) + 0.001
          sleep_time = @flood_sleep_min if sleep_time < @flood_sleep_min
        else
          sleep_time = @flood_sleep_min
        end
        
        sleep(sleep_time)
        
        @message_count = 0
      end
      
      @message_time = Time.now()
    end
    
    def put_or_type_message(text)
      put_message(text)
    end
    
    def puts_or_types_message(text)
      puts_message(text)
    end
    
    def puts_or_types_safe_message(text)
      puts_or_types_message(text)
      prevent_flood()
    end
    
    def puts_safe_message(text)
      puts_message(text)
      prevent_flood()
    end
    
    def types_safe_message(text)
      types_message(text)
      prevent_flood()
    end
    
    def puts_chat_message(text)
      puts_safe_message(";#{text}")
    end
    
    def puts_chat_message_to(channel,text)
      puts_safe_message(";#{channel};#{text}")
    end
    
    def puts_freq_message(text)
      puts_safe_message(%Q{"#{text}})
    end
    
    def puts_private_message(text)
      puts_safe_message("/#{text}")
    end
    
    def puts_private_message_to(name,text)
      puts_safe_message(":#{name}:#{text}")
    end
    
    def puts_private_message_to_last(last,text=nil)
      if text.nil?()
        text = last
        last = 1
      end
      
      put_or_type_message('::')
      
      while (last -= 1) > 0
        put_or_type_message(':')
      end
      
      puts_safe_message(text)
    end
    
    def puts_pub_message(text)
      puts_safe_message(text)
    end
    
    def puts_q_chat()
      puts_safe_message('?chat')
    end
    
    def puts_q_chat_to(*names)
      puts_safe_message("?chat=#{names.join(',')}")
    end
    
    def puts_q_enter()
      puts_safe_message('?enter')
    end
    
    def puts_q_find(player)
      puts_safe_message("?find #{player}")
    end
    
    def puts_q_kill()
      puts_safe_message('?kill')
    end
    
    def puts_q_leave()
      puts_safe_message('?leave')
    end
    
    def puts_q_loadmacro(filename)
      puts_safe_message("?loadmacro #{filename}")
    end
    
    def puts_q_log()
      puts_safe_message('?log')
    end
    
    def puts_q_log_to(filename)
      puts_safe_message("?#{filename}")
    end
    
    def puts_q_logbuffer()
      puts_safe_message('?logbuffer')
    end
    
    def puts_q_logbuffer_to(filename)
      puts_safe_message("?#{filename}")
    end
    
    def puts_q_namelen()
      puts_safe_message('?namelen')
    end
    
    def puts_q_namelen_to(namelen)
      puts_safe_message("?namelen=#{namelen}")
    end
    
    def puts_q_lines()
      puts_safe_message('?lines')
    end
    
    def puts_q_lines_to(lines)
      puts_safe_message("?lines=#{lines}")
    end
    
    def puts_q_savemacro(filename)
      puts_safe_message("?savemacro #{filename}")
    end
    
    def puts_q_spec()
      puts_safe_message('?spec')
    end
    
    def puts_q_team()
      puts_safe_message('?team')
    end
    
    def puts_squad_message(text)
      puts_safe_message("##{text}")
    end
    
    def puts_squad_message_to(squad,text)
      puts_safe_message(":##{squad}:#{text}")
    end
    
    def puts_team_message(text)
      puts_safe_message("//#{text}")
    end
    
    def puts_team_message2(text)
      puts_safe_message("'#{text}")
    end
    
    def mm_tickname()
      return MM_TICKNAME
    end
    
    def mm_selfname()
      return MM_SELFNAME
    end
    
    def mm_squad()
      return MM_SQUAD
    end
    
    def mm_freq()
      return MM_FREQ
    end
    
    def mm_bounty()
      return MM_BOUNTY
    end
    
    def mm_flags()
      return MM_FLAGS
    end
    
    def mm_energy()
      return MM_ENERGY
    end
    
    def mm_killer()
      return MM_KILLER
    end
    
    def mm_killed()
      return MM_KILLED
    end
    
    def mm_coord()
      return MM_COORD
    end
    
    def mm_area()
      return MM_AREA
    end
    
    def mm_red()
      return MM_RED
    end
    
    def mm_redname()
      return MM_REDNAME
    end
    
    def mm_redbounty()
      return MM_REDBOUNTY
    end
    
    def mm_redflags()
      return MM_REDFLAGS
    end
  end
end
end

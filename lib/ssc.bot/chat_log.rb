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
require 'forwardable'

require 'ssc.bot/ssc_file'

require 'ssc.bot/chat_log/message_parser'


module SSCBot
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class ChatLog
    extend Forwardable
    
    MAX_NAMELEN = MessageParser::MAX_NAMELEN
    
    def_delegators :@parser,:namelen,:namelen=,:parse,:regex_cache,:strict?,:strict=
    
    attr_reader? :alive
    attr_accessor :file_mode
    attr_reader :file_opt
    attr_accessor :filename
    attr_accessor :idle_time
    attr_reader :messages
    attr_reader :observers
    attr_reader :parser
    attr_accessor? :store_history
    attr_reader :thread
    
    def initialize(filename,file_mode: 'rt',file_opt: {},idle_time: 0.250,store_history: true,**kargs)
      super()
      
      parser_args = kargs.slice(*MessageParser::INIT_PARAMS)
      
      @alive = false
      @file_mode = file_mode
      @file_opt = file_opt
      @filename = filename
      @idle_time = idle_time
      @messages = []
      @observers = {}
      @parser = MessageParser.new(**parser_args)
      @semaphore = Mutex.new()
      @store_history = store_history
      @thread = nil
    end
    
    def add_observer(observer=nil,*funcs,type: :all,&block)
      type_observers = fetch_observers(type)
      
      if !observer.nil?()
        funcs << :call if funcs.empty?()
        
        type_observers << Observer.new(observer,*funcs)
      end
      
      if !block.nil?()
        type_observers << Observer.new(block,:call)
      end
    end
    
    def add_observers(*observers,type: :all,func: :call,&block)
      type_observers = fetch_observers(type)
      
      observers.each() do |observer|
        type_observers << Observer.new(observer,func)
      end
      
      if !block.nil?()
        type_observers << Observer.new(block,:call)
      end
    end
    
    def clear_history()
      @messages.clear()
    end
    
    def count_observers(type=nil)
      # TODO: implement
    end
    
    def delete_observers(*observers,type: nil)
      # TODO: implement
    end
    
    def fetch_observers(type=:all)
      type_observers = @observers[type]
      
      if type_observers.nil?()
        type_observers = []
        @observers[type] = type_observers
      end
      
      return type_observers
    end
    
    def notify_observers(message)
      all_observers = @observers[:all]
      type_observers = @observers[message.type]
      
      if !all_observers.nil?()
        all_observers.each() do |observer|
          observer.notify(self,message)
        end
      end
      
      if !type_observers.nil?()
        type_observers.each() do |observer|
          observer.notify(self,message)
        end
      end
    end
    
    def run()
      @semaphore.synchronize() do
        return if @alive # Already running
      end
      
      stop() # Justin Case
      
      @semaphore.synchronize() do
        @alive = true
        
        SSCFile.soft_touch(@filename) # Create the file if it doesn't exist
        
        @thread = Thread.new() do
          SSCFile.open(@filename,@file_mode,**@file_opt) do |fin|
            fin.seek_to_end()
            
            while @alive
              while !(line = fin.get_line()).nil?()
                message = @parser.parse(line)
                
                notify_observers(message)
                
                @messages << message if @store_history
              end
              
              sleep(@idle_time)
            end
          end
        end
      end
    end
    
    def stop(wait_time=5)
      @semaphore.synchronize() do
        @alive = false
        
        if !@thread.nil?()
          if @thread.alive?()
            # First, try to kill it gracefully (waiting X secs).
            @thread.join(@idle_time + wait_time)
            
            # Die!
            @thread.kill() if @thread.alive?()
          end
          
          @thread = nil
        end
      end
    end
    
    ###
    # @author Jonathan Bradley Whited (@esotericpig)
    # @since  0.1.0
    ###
    class Observer
      def initialize(object,*funcs)
        super()
        
        raise ArgumentError,'empty funcs' if funcs.empty?()
        
        @funcs = funcs
        @object = object
      end
      
      def notify(chat_log,message)
        @funcs.each() do |func|
          @object.__send__(func,chat_log,message)
        end
      end
    end
  end
end
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
require 'set'

require 'ssc.bot/ssc_file'

require 'ssc.bot/chat_log/message'
require 'ssc.bot/chat_log/message_parser'
require 'ssc.bot/chat_log/messages'


module SSCBot
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class ChatLog
    extend Forwardable
    
    MAX_NAMELEN = MessageParser::MAX_NAMELEN
    
    def_delegators(:@parser,
      :autoset_namelen?,
      :autoset_namelen=,
      :check_history_count,
      :check_history_count=,
      :messages,
      :namelen,
      :namelen=,
      :regex_cache,
      :store_history?,
      :store_history=,
      :strict?,
      :strict=,
      
      :parse,
    )
    
    attr_reader? :alive
    attr_accessor :file_mode
    attr_reader :file_opt
    attr_accessor :filename
    attr_accessor :idle_time
    attr_reader :observers
    attr_reader :parser
    attr_reader :thread
    
    def initialize(filename,file_mode: 'rt',file_opt: {},idle_time: 0.250,**parser_kargs)
      super()
      
      @alive = false
      @file_mode = file_mode
      @file_opt = file_opt
      @filename = filename
      @idle_time = idle_time
      @observers = {}
      @parser = MessageParser.new(**parser_kargs)
      @semaphore = Mutex.new()
      @thread = nil
    end
    
    def add_observer(observer=nil,*funcs,type: :any,&block)
      if observer.nil?() && block.nil?()
        raise ArgumentError,'no observer'
      end
      
      check_type(type)
      
      type_observers = fetch_observers(type: type)
      
      if !observer.nil?()
        funcs << :call if funcs.empty?()
        
        type_observers << Observer.new(observer,*funcs)
      end
      
      if !block.nil?()
        type_observers << Observer.new(block,:call)
      end
    end
    
    def add_observers(*observers,type: :any,func: :call,&block)
      if observers.empty?() && block.nil?()
        raise ArgumentError,'no observer'
      end
      
      check_type(type)
      
      type_observers = fetch_observers(type: type)
      
      observers.each() do |observer|
        type_observers << Observer.new(observer,func)
      end
      
      if !block.nil?()
        type_observers << Observer.new(block,:call)
      end
    end
    
    def check_type(type,nil_ok: false)
      if type.nil?()
        if !nil_ok
          raise ArgumentError,"invalid type{#{type.inspect()}}"
        end
      else
        if type != :any && !Message.valid_type?(type)
          raise ArgumentError,"invalid type{#{type.inspect()}}"
        end
      end
    end
    
    def clear_content()
      SSCFile.clear(@filename)
    end
    
    def count_observers(type: nil)
      check_type(type,nil_ok: true)
      
      count = 0
      
      if type.nil?()
        @observers.each_value() do |type_observers|
          count += type_observers.length
        end
      else
        type_observers = @observers[type]
        
        if !type_observers.nil?()
          count += type_observers.length
        end
      end
      
      return count
    end
    
    def delete_observer(observer,type: nil)
      delete_observers(observer,type: type)
    end
    
    def delete_observers(*observers,type: nil)
      check_type(type,nil_ok: true)
      
      if observers.empty?()
        if type.nil?()
          @observers.clear()
        else
          type_observers = @observers[type]
          
          if !type_observers.nil?()
            type_observers.clear()
          end
        end
      else
        observers = observers.to_set()
        
        if type.nil?()
          @observers.each_value() do |type_observers|
            type_observers.delete_if() do |observer|
              observers.include?(observer.object)
            end
          end
        else
          type_observers = @observers[type]
          
          if !type_observers.nil?()
            type_observers.delete_if() do |observer|
              observers.include?(observer.object)
            end
          end
        end
      end
    end
    
    def fetch_observers(type: :any)
      check_type(type)
      
      type_observers = @observers[type]
      
      if type_observers.nil?()
        type_observers = []
        @observers[type] = type_observers
      end
      
      return type_observers
    end
    
    def notify_observers(message)
      any_observers = @observers[:any]
      type_observers = @observers[message.type]
      
      if !any_observers.nil?()
        any_observers.each() do |observer|
          observer.notify(self,message)
        end
      end
      
      if !type_observers.nil?()
        type_observers.each() do |observer|
          observer.notify(self,message)
        end
      end
    end
    
    def run(seek_to_end: true)
      @semaphore.synchronize() do
        return if @alive # Already running
      end
      
      stop() # Justin Case
      
      @semaphore.synchronize() do
        @alive = true
        
        soft_touch() # Create the file if it doesn't exist
        
        @thread = Thread.new() do
          SSCFile.open(@filename,@file_mode,**@file_opt) do |fin|
            fin.seek_to_end() if seek_to_end
            
            while @alive
              while !(line = fin.get_line()).nil?()
                message = @parser.parse(line)
                
                notify_observers(message)
              end
              
              sleep(@idle_time)
            end
          end
        end
      end
    end
    
    def soft_touch()
      SSCFile.soft_touch(@filename)
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
      attr_reader :funcs
      attr_reader :object
      
      def initialize(object,*funcs)
        super()
        
        raise ArgumentError,'empty funcs' if funcs.empty?()
        
        @funcs = funcs
        @object = object
      end
      
      def notify(chatlog,message)
        @funcs.each() do |func|
          @object.__send__(func,chatlog,message)
        end
      end
    end
  end
end

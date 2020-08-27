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


begin
  require 'java'
rescue LoadError => e
  raise e.exception('Must use JRuby for JRobotMessageSender')
end

require 'attr_bool'

require 'ssc.bot/util'

require 'ssc.bot/user/message_sender'

java_import 'java.awt.Robot'
java_import 'java.awt.Toolkit'

java_import 'java.awt.datatransfer.Clipboard'
java_import 'java.awt.datatransfer.ClipboardOwner'
java_import 'java.awt.datatransfer.StringSelection'

java_import 'java.awt.event.KeyEvent'


module SSCBot
module User
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class JRobotMessageSender < MessageSender
    attr_accessor :clipboard
    attr_accessor :msg_key
    attr_accessor :os
    attr_accessor :robot
    attr_accessor :shortcut_paste
    attr_accessor :shortcut_paste_default
    attr_accessor :shortcut_paste_macos
    attr_accessor? :warn_user
    attr_accessor :warn_user_key
    attr_accessor :warn_user_sleep
    
    def initialize(auto_delay: 110,msg_key: nil,os: Util::OS,warn_user: false,warn_user_key: KeyEvent::VK_BACK_SPACE,warn_user_sleep: 0.747,**kargs)
      super(**kargs)
      
      @clipboard = Toolkit.getDefaultToolkit().getSystemClipboard()
      @msg_key = msg_key
      @os = os
      @robot = Robot.new()
      @warn_user = warn_user
      @warn_user_key = warn_user_key
      @warn_user_sleep = warn_user_sleep
      
      @robot.setAutoDelay(auto_delay)
      
      @shortcut_paste = ->(ms) do
        if ms.os == :macos
          @shortcut_paste_macos.call(ms)
        else
          @shortcut_paste_default.call(ms)
        end
      end
      @shortcut_paste_default = ->(ms) { ms.roll_keys(KeyEvent::VK_CONTROL,KeyEvent::VK_V) }
      @shortcut_paste_macos = ->(ms) { ms.roll_keys(KeyEvent::VK_META,KeyEvent::VK_V) }
    end
    
    def backspace()
      return type_key(KeyEvent::VK_BACK_SPACE)
    end
    
    def copy(str)
      @clipboard.setContents(StringSelection.new(str),nil)
      
      return self
    end
    
    def enter()
      return type_key(KeyEvent::VK_ENTER)
    end
    
    def paste(str=nil)
      copy(str) unless str.nil?()
      
      @shortcut_paste.call(self)
      
      return self
    end
    
    def press_key(*key_codes)
      key_codes.each() do |key_code|
        @robot.keyPress(key_code)
      end
      
      return self
    end
    
    def put(message)
      # If do type_msg_key() and then warn_user(), then a backspace from
      #   warn_user() will cancel out the msg key.
      # Could do type_msg_key().warn_user().type_msg_key(), but then if the
      #   client is in windowed mode and msg key is a tab, then a backspace
      #   from warn_user() will do nothing.
      return warn_user().
             type_msg_key().
             paste(message)
    end
    
    def release_key(*key_codes)
      key_codes.each() do |key_code|
        @robot.keyRelease(key_code)
      end
      
      return self
    end
    
    def roll_keys(*key_codes)
      key_codes.each() do |key_code|
        @robot.keyPress(key_code)
      end
      
      (key_codes.length - 1).downto(0) do |i|
        @robot.keyRelease(key_codes[i])
      end
      
      return self
    end
    
    def send_message()
      enter()
    end
    
    def type(message)
      # TODO: implement type(message)
      super(message)
    end
    
    def type_key(*key_codes)
      key_codes.each() do |key_code|
        @robot.keyPress(key_code)
        @robot.keyRelease(key_code)
      end
      
      return self
    end
    
    def type_msg_key()
      if @msg_key
        if @msg_key.respond_to?(:call)
          @msg_key.call(self)
        else
          type_key(@msg_key)
        end
      end
      
      return self
    end
    
    def warn_user()
      if @warn_user
        if @warn_user_key.respond_to?(:call)
          @warn_user_key.call(self)
        else
          press_key(@warn_user_key)
          sleep(@warn_user_sleep)
          release_key(@warn_user_key)
        end
      end
      
      return self
    end
  end
end
end

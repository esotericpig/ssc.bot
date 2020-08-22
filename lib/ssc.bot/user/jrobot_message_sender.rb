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
    PASTE = ->(ms) { (ms.os == :macos) ? PASTE_MACOS.call(ms) : PASTE_DEFAULT.call(ms) }
    PASTE_DEFAULT = ->(ms) { ms.roll_keys(KeyEvent::VK_CONTROL,KeyEvent::VK_V) }
    PASTE_MACOS = ->(ms) { ms.roll_keys(KeyEvent::VK_META,KeyEvent::VK_V) }
    
    attr_accessor :clipboard
    attr_accessor :os
    attr_accessor :robot
    
    def initialize(auto_delay: 110,os: Util::OS,**kargs)
      super(**kargs)
      
      @clipboard = Toolkit.getDefaultToolkit().getSystemClipboard()
      @os = os
      @robot = Robot.new()
      
      @robot.setAutoDelay(auto_delay)
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
      
      PASTE.call(self)
      
      return self
    end
    
    def put(message)
      return paste(message)
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
    
    def type_key(key_code)
      @robot.keyPress(key_code)
      @robot.keyRelease(key_code)
      
      return self
    end
    
    def type_keys(*key_codes)
      key_codes.each() do |key_code|
        type_key(key_code)
      end
      
      return self
    end
  end
end
end

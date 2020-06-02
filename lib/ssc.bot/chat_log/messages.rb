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

require 'ssc.bot/chat_log/message'


module SSCBot
class ChatLog
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class PlayerMessage < Message
    attr_reader :message
    attr_reader :name
    
    def initialize(line,type:,name:,message:)
      super(line,type: type)
      
      @message = message
      @name = name
    end
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class ChatMessage < PlayerMessage
    attr_reader :channel
    
    def initialize(line,channel:,name:,message:)
      super(line,type: :chat,name: name,message: message)
      
      @channel = channel
    end
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class FreqMessage < PlayerMessage
    def initialize(line,name:,message:)
      super(line,type: :freq,name: name,message: message)
    end
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class KillMessage < Message
    attr_reader :bounty
    attr_reader :killed
    attr_reader :killer
    
    def initialize(line,killed:,bounty:,killer:)
      super(line,type: :kill)
      
      @bounty = bounty
      @killed = killed
      @killer = killer
    end
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class PrivateMessage < PlayerMessage
    def initialize(line,name:,message:)
      super(line,type: :private,name: name,message: message)
    end
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class PubMessage < PlayerMessage
    def initialize(line,name:,message:)
      super(line,type: :pub,name: name,message: message)
    end
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class QFindMessage < Message
    attr_reader :arena
    attr_reader :days
    attr_reader :find_type # [:arena,:days,:hours,:zone]
    attr_reader :hours
    attr_reader? :more
    attr_reader :player
    attr_reader? :private
    attr_reader :zone
    
    def initialize(line,find_type:,arena: nil,days: nil,hours: nil,more: false,player: nil,private: false,zone: nil)
      super(line,type: %s{?find})
      
      @arena = arena
      @days = days
      @find_type = find_type
      @hours = hours
      @more = more
      @player = player
      @private = private
      @zone = zone
    end
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class QLogMessage < Message
    attr_reader :filename
    attr_reader :log_type # [:open,:close]
    
    def initialize(line,log_type:,filename: nil)
      super(line,type: %s{?log})
      
      @filename = filename
      @log_type = log_type
    end
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class QNamelenMessage < Message
    attr_reader :namelen
    
    def initialize(line,namelen:)
      super(line,type: %s{?namelen})
      
      @namelen = namelen
    end
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class RemoteMessage < PlayerMessage
    attr_reader? :own
    attr_reader? :squad
    
    def initialize(line,own:,squad:,name:,message:)
      super(line,type: :remote,name: name,message: message)
      
      @own = own
      @squad = squad
    end
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class TeamMessage < PlayerMessage
    def initialize(line,name:,message:)
      super(line,type: :team,name: name,message: message)
    end
  end
end
end

#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Bot.
# Copyright (c) 2020-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


require 'attr_bool'
require 'set'

require 'ssc.bot/error'
require 'ssc.bot/util'

require 'ssc.bot/chat_log/message'
require 'ssc.bot/chat_log/messages'

module SSCBot; class ChatLog
  ###
  # @author Jonathan Bradley Whited
  # @since  0.1.0
  ###
  class MessageParser
    extend AttrBool::Ext

    MAX_NAMELEN = 24

    attr_accessor? :autoset_namelen
    attr_accessor :check_history_count
    attr_reader :commands
    attr_reader :messages
    attr_accessor :namelen
    attr_reader :regex_cache
    attr_accessor? :store_history
    attr_accessor? :strict

    def initialize(autoset_namelen: true,check_history_count: 5,namelen: nil,store_history: true,strict: true)
      super()

      @autoset_namelen = autoset_namelen
      @check_history_count = check_history_count
      @commands = {}
      @messages = []
      @namelen = namelen
      @regex_cache = {}
      @store_history = store_history
      @strict = strict
    end

    # The Ruby interpreter should cache the args' default values,
    # so no reason to manually cache them unless a variable is involved inside.
    #
    # @example Default Format
    #   'X Name> Message'
    def match_player(line,type_name:,name_prefix: '',name_suffix: '> ',type_prefix: %r{..},use_namelen: true)
      cached_regex = @regex_cache[type_name]

      if cached_regex.nil?()
        cached_regex = {}
        @regex_cache[type_name] = cached_regex
      end

      use_namelen &&= !@namelen.nil?()
      key = use_namelen ? @namelen : :no_namelen
      regex = cached_regex[key]

      if regex.nil?()
        name_prefix = Util.quote_str_or_regex(name_prefix)
        name_suffix = Util.quote_str_or_regex(name_suffix)
        type_prefix = Util.quote_str_or_regex(type_prefix)

        if use_namelen
          name = /.{#{@namelen}}/
        else
          name = /.*?\S/
        end

        name = Util.quote_str_or_regex(name)

        # Be careful to not use spaces ' ', but to use '\\ ' (or '\s') instead
        #   because of the '/x' option.
        regex = /
          \A#{type_prefix}
          #{name_prefix}(?<name>#{name})#{name_suffix}
          (?<message>.*)\z
        /x

        cached_regex[key] = regex
      end

      return regex.match(line)
    end

    def parse(line)
      if line.nil?()
        if @strict
          raise ArgumentError,"invalid line{#{line.inspect()}}"
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
          if (match = match_remote?(line))
            message = parse_remote(line,match: match)
          else
            message = parse_private(line)
          end
        when 'T'
          message = parse_team(line)
        else
          # Check this one first to prevent abuse from pubbers.
          if (match = match_pub?(line))
            message = parse_pub(line,match: match)
          else
            if (match = match_kill?(line))
              message = parse_kill(line,match: match)
            elsif (match = match_q_log?(line))
              message = parse_q_log(line,match: match)
            elsif (match = match_q_namelen?(line))
              message = parse_q_namelen(line,match: match)
            else
              # These are last because too flexible.
              if (match = match_q_find?(line))
                message = parse_q_find(line,match: match)
              end
            end
          end
        end
      end

      if message.nil?()
        message = Message.new(line,type: :unknown)
      end

      if @store_history
        @messages << message
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

      channel = match[:channel].to_i()

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
      bounty = match[:bounty].to_i()
      killer = match[:killer]

      return KillMessage.new(line,killed: killed,bounty: bounty,killer: killer)
    end

    # @example Default Format
    #   'X Name> Message'
    def parse_player(line,type_name:,match: :default)
      if match.nil?()
        if @strict
          raise ParseError,"invalid #{type_name} message{#{line}}"
        else
          return nil
        end
      elsif match == :default
        # Use type_name of :player (not passed in param) for regex_cache.
        match = match_player(line,type_name: :player)
      end

      name = Util.u_lstrip(match[:name])
      message = match[:message]

      if name.empty?() || name.length > MAX_NAMELEN
        if @strict
          raise ParseError,"invalid player name for #{type_name} message{#{line}}"
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
    def parse_pub(line,match:)
      player = parse_player(line,type_name: :pub,match: match)

      return nil if player.nil?()

      cmd = Util.u_strip(player.message).downcase()

      if cmd.start_with?('?find')
        store_command(:pub,%s{?find}) # See: match_q_find?()
      end

      return PubMessage.new(line,name: player.name,message: player.message)
    end

    # @example Format
    #   '  Not online, last seen more than 10 days ago'
    #   '  Not online, last seen 9 days ago'
    #   '  Not online, last seen 18 hours ago'
    #   '  Not online, last seen 0 hours ago'
    #   '  Name - Public 0'
    #   '  TWCore - (Private arena)'
    #   '  Name is in SSCJ Devastation'
    #   '  Name is in SSCC Metal Gear CTF'
    def parse_q_find(line,match:)
      if match.nil?()
        if @strict
          raise ParseError,"invalid ?find message{#{line}}"
        else
          return nil
        end
      end

      caps = match.named_captures
      q_find = nil

      if (days = caps['days'])
        more = caps.key?('more')
        days = days.to_i()

        q_find = QFindMessage.new(line,find_type: :days,more: more,days: days)
      elsif (hours = caps['hours'])
        hours = hours.to_i()

        q_find = QFindMessage.new(line,find_type: :hours,hours: hours)
      elsif (player = caps['player'])
        if (arena = caps['arena'])
          private = (arena == '(Private arena)')

          q_find = QFindMessage.new(line,find_type: :arena,player: player,arena: arena,private: private)
        elsif (zone = caps['zone'])
          q_find = QFindMessage.new(line,find_type: :zone,player: player,zone: zone)
        end
      end

      if q_find.nil?() && @strict
        raise ParseError,"invalid ?find message{#{line}}"
      end

      return q_find
    end

    # @example Format
    #   '  Log file open: session.log'
    #   '  Log file closed'
    def parse_q_log(line,match:)
      if match.nil?()
        if @strict
          raise ParseError,"invalid ?log message{#{line}}"
        else
          return nil
        end
      end

      filename = match.named_captures['filename']
      log_type = filename.nil?() ? :close : :open

      return QLogMessage.new(line,log_type: log_type,filename: filename)
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

      namelen = match[:namelen].to_i()

      if namelen < 1
        if @strict
          raise ParseError,"invalid namelen for ?namelen message{#{line}}"
        else
          return nil
        end
      elsif namelen > MAX_NAMELEN
        warn("namelen{#{namelen}} > max{#{MAX_NAMELEN}} for ?namelen message{#{line}}",uplevel: 0)
      end

      if @autoset_namelen
        @namelen = namelen
      end

      return QNamelenMessage.new(line,namelen: namelen)
    end

    # @example Format
    #   # NOT affected by namelen.
    #   'P :Self.Name:Message'
    #   'P (Name)>Message'
    def parse_remote(line,match:)
      player = parse_player(line,type_name: %s{remote.private},match: match)

      return nil if player.nil?()

      own = (line[2] == ':')
      squad = (player.name[0] == '#')

      return RemoteMessage.new(line,
        own: own,squad: squad,
        name: player.name,message: player.message,
      )
    end

    # @example Format
    #   'T Name> Message'
    def parse_team(line)
      player = parse_player(line,type_name: :team)

      return nil if player.nil?()

      return TeamMessage.new(line,name: player.name,message: player.message)
    end

    def clear_history()
      @messages.clear()
    end

    def reset_namelen()
      @namelen = nil
    end

    def store_command(type,name)
      type_hash = @commands[type]

      if type_hash.nil?()
        type_hash = {}
        @commands[type] = type_hash
      end

      type_hash[name] = @messages.length # Index of when command was found/stored
    end

    def command?(type,name,delete: true)
      return true if @check_history_count < 1

      type_hash = @commands[type]

      if !type_hash.nil?()
        index = type_hash[name]

        if !index.nil?() && (@messages.length - index) <= @check_history_count
          type_hash.delete(name) if delete

          return true
        end
      end

      return false
    end

    # @example Format
    #   '  Killed.Name(100) killed by: Killer.Name'
    def match_kill?(line)
      return false if line.length < 19 # '  N(0) killed by: N'

      return /\A  (?<killed>.*?\S)\((?<bounty>\d+)\) killed by: (?<killer>.*?\S)\z/.match(line)
    end

    # @example Format
    #   '  Name> Message'
    def match_pub?(line)
      return false if line.length < 5 # '  N> '

      match = match_player(line,type_name: :pub,type_prefix: '  ')

      if !match.nil?()
        name = Util.u_lstrip(match[:name])

        if name.empty?() || name.length > MAX_NAMELEN
          return false
        end
      end

      return match
    end

    # @example Format
    #   '  Not online, last seen more than 10 days ago'
    #   '  Not online, last seen 9 days ago'
    #   '  Not online, last seen 18 hours ago'
    #   '  Not online, last seen 0 hours ago'
    #   '  Name - Public 0'
    #   '  TWCore - (Private arena)'
    #   '  Name is in SSCJ Devastation'
    #   '  Name is in SSCC Metal Gear CTF'
    def match_q_find?(line)
      return false if line.length < 7 # '  N - A'
      return false unless command?(:pub,%s{?find})

      if line.start_with?('  Not online, last seen ')
        match = line.match(/(?<more>more) than (?<days>\d+) days ago\z/)
        match = line.match(/(?<days>\d+) days? ago\z/) if match.nil?()
        match = line.match(/(?<hours>\d+) hours? ago\z/) if match.nil?()

        return match
      else
        match = line.match(/\A  (?<player>.+) is in (?<zone>.+)\z/)
        match = line.match(/\A  (?<player>.+) - (?<arena>.+)\z/) if match.nil?()

        if match
          caps = match.named_captures

          player = caps['player']

          return false if player.length > MAX_NAMELEN

          if caps.key?('arena')
            area = caps['arena']
          elsif caps.key?('zone')
            area = caps['zone']
          else
            return false
          end

          # If do /\A  (?<player>[^[[:space:]]].+[^[[:space:]])/, then it won't
          #   capture names/zones/arenas that are only 1 char long, so do this.
          [player[0],player[-1],area[0],area[-1]].each() do |c|
            if c =~ /[[:space:]]/
              return false
            end
          end

          return match
        end
      end

      return false
    end

    # @example Format
    #   '  Log file open: session.log'
    #   '  Log file closed'
    def match_q_log?(line)
      return false if line.length < 17

      match = /\A  Log file open: (?<filename>.+)\z/.match(line)
      match = /\A  Log file closed\z/.match(line) if match.nil?()

      return match
    end

    # @example Format
    #   '  Message Name Length: 24'
    def match_q_namelen?(line)
      return false if line.length < 24 # '...: 0'
      return false if line[21] != ':'

      return /\A  Message Name Length: (?<namelen>\d+)\z/.match(line)
    end

    # @example Format
    #   # NOT affected by namelen.
    #   'P :Self.Name:Message'
    #   'P (Name)>Message'
    def match_remote?(line)
      return false if line.length < 5 # 'P :N:'

      case line[2]
      when ':'
        return match_player(line,type_name: %s{remote.out},
          name_prefix: ':',name_suffix: ':',use_namelen: false)
      when '('
        return match_player(line,type_name: %s{remote.in},
          name_prefix: '(',name_suffix: ')>',use_namelen: false)
      end

      return false
    end
  end
end; end

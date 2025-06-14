# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Bot.
# Copyright (c) 2020-2021 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'attr_bool'
require 'set'

module SSCBot
class ChatLog
  ###
  # The base class of all parsed messages from a chat log file.
  #
  # @author Bradley Whited
  # @since  0.1.0
  ###
  class Message
    extend AttrBool::Ext

    # Adds +type+ to the list of valid {TYPES}
    # and creates a boolean method for it ending with a +?+.
    #
    # @param type [Symbol,String] the new type to add
    def self.add_type(type)
      type = type.to_sym

      return if TYPES.include?(type)

      TYPES.add(type)

      name = type.to_s.sub('?','q_')

      define_method(:"type_#{name}?") do
        return @type == type
      end
    end

    # Valid types of messages.
    #
    # You can add your own custom type(s) that you parse manually:
    #   SSCBot::ChatLog::Message.add_type(:custom)
    TYPES = Set.new

    # In order of F1 Help box.
    %i[
      pub team private remote freq chat

      ?lines ?namelen ?ignore ?nopubchat ?obscene ?away ?log ?logbuffer
      ?kill kill ?enter enter ?leave leave ?message ?messages ?chat

      ?status ?scorereset ?team ?spec ?target ?time ?flags ?score ?crown
      ?best ?buy

      ?owner ?password ?usage ?userid ?find ?ping ?packetloss ?lag ?music
      ?sound ?alarm ?sheep ?getnews

      ?squadowner ?squad ?squadlist ?loadmacro ?savemacro

      unknown
    ].each do |type|
      add_type(type)
    end

    # @param  type [Symbol] the type to check if valid
    # @return [Boolean] +true+ if +type+ is one of {TYPES}, else +false+
    def self.valid_type?(type)
      return TYPES.include?(type)
    end

    attr_reader :line # @return [String] the raw (unparsed) line from the file
    attr_reader :type # @return [Symbol] what type of message this is; one of {TYPES}

    # @param line [String] the raw (unparsed) line from the file
    # @param type [Symbol] what type of message this is; must be one of {TYPES}
    def initialize(line,type:)
      type = type.to_sym

      raise ArgumentError,"invalid line{#{line.inspect}}" if line.nil?
      raise ArgumentError,"invalid type{#{type.inspect}}" if !self.class.valid_type?(type)

      @line = line
      @type = type
    end

    # A convenience method for comparing anything that responds to
    # +:to_sym():+, like +String+.
    #
    # @param  type [String,Symbol] the type to convert & compare against
    # @return [Boolean] +true+ if this message is of type +type+, else +false+
    def type?(type)
      return @type == type.to_sym
    end
  end
end
end

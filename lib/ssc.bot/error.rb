# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Bot.
# Copyright (c) 2020-2021 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module SSCBot
  ###
  # @author Bradley Whited
  # @since  0.1.0
  ###
  class Error < ::StandardError; end

  ###
  # @author Bradley Whited
  # @since  0.1.0
  ###
  class AbstractMethodError < Error
    def initialize(msg = nil)
      if msg.is_a?(Symbol)
        msg = "abstract method not implemented: #{msg}(...)"
      end

      super
    end
  end

  ###
  # @author Bradley Whited
  # @since  0.1.0
  ###
  class ParseError < Error
  end
end

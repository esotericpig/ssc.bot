# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Bot.
# Copyright (c) 2020-2021 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


require 'ssc.bot/util'

module SSCBot
  ###
  # @author Bradley Whited
  # @since  0.1.0
  ###
  class SSCFile < ::File
    DEFAULT_BUFFER_LEN = 520
    DEFAULT_ENCODING = 'Windows-1252:UTF-8'
    DEFAULT_MODE = 'rt'
    DEFAULT_SEPARATOR = /\r?\n|\r/.freeze # Instead, could use +/\R/+ for Ruby v2.0+.

    # Clear (truncate) the contents of +filename+.
    #
    # @param filename [String] the file to clear
    # @param strip [Boolean] +true+ to strip +filename+ to help prevent fat-fingering, else +false+ to not
    def self.clear_content(filename,strip: true,textmode: true,**opt)
      filename = Util.u_strip(filename) if strip

      return if filename.empty?
      return unless File.file?(filename) # Also checks if exists.

      # Clear the file.
      # - Do NOT call truncate() as it's not available on all platforms.
      self.open(filename,'w',textmode: textmode,**opt) do |file|
      end
    end

    # If +filename+ exists, then it does nothing (does *not* update time),
    # else, it creates the file.
    #
    # I just prefer this over +FileUtils.touch+.
    #
    # @param filename [String] the file to soft touch
    # @param strip [Boolean] +true+ to strip +filename+ to help prevent fat-fingering, else +false+ to not
    def self.soft_touch(filename,strip: true,textmode: true,**opt)
      filename = Util.u_strip(filename) if strip

      return if filename.empty?
      return if File.exist?(filename)

      # Create the file.
      self.open(filename,'a',textmode: textmode,**opt) do |file|
      end
    end

    def initialize(filename,mode=DEFAULT_MODE,buffer_len: DEFAULT_BUFFER_LEN,encoding: DEFAULT_ENCODING,
                   separator: DEFAULT_SEPARATOR,**opt)
      super(filename,mode,encoding: encoding,**opt)

      @sscbot_buffer = nil
      @sscbot_buffer_len = buffer_len
      @sscbot_separator = separator
    end

    # Read a universal line.
    def read_uline
      if @sscbot_buffer.nil?
        # See comment at loop below.
        # - Use gets() instead of eof?() because of this method's name.
        line = gets(nil,@sscbot_buffer_len)

        return nil if line.nil? # Still EOF?

        @sscbot_buffer = line
      end

      lines = @sscbot_buffer.split(@sscbot_separator,2)

      # Will only have 2 if there was a separator.
      if lines.length == 2
        @sscbot_buffer = lines[1]

        return lines[0]
      end

      # - Use a separator of nil to get all of the different types of newlines.
      # - Use gets() [instead of read(), etc.] to work probably with text (e.g., UTF-8)
      #   and to not throw an error at EOF (returns nil).
      while !(line = gets(nil,@sscbot_buffer_len)).nil?
        lines = line.split(@sscbot_separator,2)

        # Will only have 2 if there was a separator.
        if lines.length == 2
          line = "#{@sscbot_buffer}#{lines[0]}"
          @sscbot_buffer = lines[1]

          return line
        else
          @sscbot_buffer << line
        end
      end

      # EOF reached with text in the buffer.
      line = @sscbot_buffer
      @sscbot_buffer = nil

      return line
    end

    def seek_to_end
      result = seek(0,:END)

      read_uline # Justin Case

      return result
    end
  end
end

#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Bot.
# Copyright (c) 2020-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


require 'test_helper'

require 'ssc.bot/util'

describe SSCBot::Util do
  SPACES = "  \r\n\t  "
  SPACES_X = "#{SPACES}x#{SPACES}"

  let(:util) { SSCBot::Util }

  before do
  end

  after do
  end

  describe 'os()' do
    it 'when constant' do
      expect(util::OS).must_equal util.os()
    end

    it 'when Darwin' do
      expect(util.os('w/e Darwin w/e')).must_equal :macos
    end

    it 'when Linux' do
      expect(util.os('w/e Linux w/e')).must_equal :linux
    end

    it 'when Windows' do
      expect(util.os('w/e Windows w/e')).must_equal :windows
    end
  end

  describe 'u_blank?()' do
    it 'when nil' do
      expect(util.u_blank?(nil)).must_equal true
    end

    it 'when empty' do
      expect(util.u_blank?('')).must_equal true
    end

    it 'when spaces' do
      expect(util.u_blank?(SPACES)).must_equal true
    end

    it 'when not empty' do
      expect(util.u_blank?(' x ')).must_equal false
    end
  end

  describe 'u_lstrip()' do
    it 'when nil' do
      expect(util.u_lstrip(nil)).must_be_nil
    end

    it 'when spaces' do
      expect(util.u_lstrip(SPACES_X)).must_equal "x#{SPACES}"
    end
  end

  describe 'u_rstrip()' do
    it 'when nil' do
      expect(util.u_rstrip(nil)).must_be_nil
    end

    it 'when spaces' do
      expect(util.u_rstrip(SPACES_X)).must_equal "#{SPACES}x"
    end
  end

  describe 'u_strip()' do
    it 'when nil' do
      expect(util.u_strip(nil)).must_be_nil
    end

    it 'when spaces' do
      expect(util.u_strip(SPACES_X)).must_equal 'x'
    end
  end
end

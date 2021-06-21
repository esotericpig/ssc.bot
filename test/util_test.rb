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
  let(:util) { SSCBot::Util }

  let(:spaces) { "  \r\n\t  " }
  let(:spaces_x) { "#{spaces}x#{spaces}" }

  before do
  end

  after do
  end

  describe '.os()' do
    it 'should match the constant' do
      expect(util::OS).must_equal util.os
    end

    it 'should match macOS' do
      expect(util.os('w/e Darwin w/e')).must_equal :macos
    end

    it 'should match Linux' do
      expect(util.os('w/e Linux w/e')).must_equal :linux
    end

    it 'should match Windows' do
      expect(util.os('w/e Windows w/e')).must_equal :windows
    end
  end

  describe '.u_blank?()' do
    it 'should match if nil' do
      expect(util.u_blank?(nil)).must_equal true
    end

    it 'should match if empty' do
      expect(util.u_blank?('')).must_equal true
    end

    it 'should strip spaces' do
      expect(util.u_blank?(spaces)).must_equal true
    end

    it 'should not match if not empty' do
      expect(util.u_blank?(' x ')).must_equal false
    end
  end

  describe '.u_lstrip()' do
    it 'should allow nil' do
      expect(util.u_lstrip(nil)).must_be_nil
    end

    it 'should strip left/leading spaces' do
      expect(util.u_lstrip(spaces_x)).must_equal "x#{spaces}"
    end
  end

  describe '.u_rstrip()' do
    it 'should allow nil' do
      expect(util.u_rstrip(nil)).must_be_nil
    end

    it 'should strip right/trailing spaces' do
      expect(util.u_rstrip(spaces_x)).must_equal "#{spaces}x"
    end
  end

  describe '.u_strip()' do
    it 'should allow nil' do
      expect(util.u_strip(nil)).must_be_nil
    end

    it 'should strip all spaces' do
      expect(util.u_strip(spaces_x)).must_equal 'x'
    end
  end
end

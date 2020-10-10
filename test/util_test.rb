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

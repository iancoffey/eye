require File.dirname(__FILE__) + '/../spec_helper'

describe "Eye::Group" do

  describe "correctly chain calls" do
    it "1" do
      @g = Eye::Group.new('gr', {:chain => {:start => {:type => :sync, :command => :start, :grace => 7}}})
      mock(@g).sync_queue(:start, 7)
      @g.start
    end

    it "1.1" do
      @g = Eye::Group.new('gr', {:chain => {:start => {:type => :async, :command => :start, :grace => 7}}})
      mock(@g).async_queue(:start, 7)
      @g.start
    end

    it "2" do
      @g = Eye::Group.new('gr', {:chain => {:start => {:type => :sync, :command => :start}}})
      mock(@g).sync_queue(:start, 5)
      @g.start
    end

    it "3" do
      @g = Eye::Group.new('gr', {:chain => {:start => {:command => :start}}})
      mock(@g).async_queue(:start, 5)
      @g.start
    end

    it "4" do
      @g = Eye::Group.new('gr', {:chain => {:start => {:command => :restart}}})
      dont_allow(@g).async_queue
      @g.restart
    end

    it "4.1" do
      @g = Eye::Group.new('gr', {:chain => {:restart => {:command => :restart}}})
      mock(@g).async_queue(:restart, 5)
      @g.restart
    end

    it "5" do
      @g = Eye::Group.new('gr', {})
      mock(@g).async_all(:restart)
      @g.restart
    end

  end

end
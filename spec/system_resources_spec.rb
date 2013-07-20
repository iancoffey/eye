require File.dirname(__FILE__) + '/spec_helper'

describe "Eye::SystemResources" do

  it "should get memory" do
    x = Eye::SystemResources.memory($$)
    x.should > 100
    x.should < 300_000
  end

  it "should get cpu" do
    x = Eye::SystemResources.cpu($$)
    x.should >= 0
    x.should <= 150
  end

  it "should get start time" do
    x = Eye::SystemResources.start_time($$)
    x.length.should >= 4
  end

  it "should get childs" do
    x = Eye::SystemResources.childs($$)
    x.is_a?(Array).should == true
    x.first.should > 0
    x.size.should > 0
    x.all?{|c| c > 0 }.should == true
  end

  it "should cache and update when interval" do
    stub(Eye::System).ps_aux{ {$$ => {:rss => 123}} }

    silence_warnings{ Eye::SystemResources::PsAxActor::UPDATE_INTERVAL = 1 }

    x1 = Eye::SystemResources.memory($$)
    x2 = Eye::SystemResources.memory($$)
    x1.should == x2

    sleep 0.5
    x3 = Eye::SystemResources.memory($$)
    x1.should == x3

    stub(Eye::System).ps_aux{ {$$ => {:rss => 124}} }

    sleep 0.7
    x4 = Eye::SystemResources.memory($$)
    x1.should == x4 # first value is old

    sleep 0.1

    x5 = Eye::SystemResources.memory($$)
    x1.should_not == x5 # seconds is new
  end

end

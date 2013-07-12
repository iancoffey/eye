require File.dirname(__FILE__) + '/spec_helper'

describe "Eye::Logger" do
  it "should use smart logger with auto prefix" do
    Eye::Process.logger.prefix.should == "Eye::Process"
    Eye.logger.prefix.should == "Eye"
    Eye::Checker.logger.prefix.should == "Eye::Checker"
    Eye::Checker.create(123, {:type => :cpu, :every => 5.seconds, :times => 1}, "some").logger.prefix.should == "some"
    Eye::Controller.new.logger.prefix.should == "<Eye::Controller>"
    Eye::Process.new(C.p1).__logger__.prefix.should == "main:default:blocking process"
  end
end
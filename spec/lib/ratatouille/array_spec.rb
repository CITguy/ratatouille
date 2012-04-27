require 'spec_helper'

describe "Ratatouille::ArrayMethods" do
  [ :ratify_each, 
    :min_length, 
    :max_length, 
    :length_between
  ].each do |m|
    it "block context should respond to #{m}" do
      r = nil
      RatifierTest.new([]) { r = self }
      r.should respond_to m
    end
  end

  describe "ratify_each" do
    it "should set block name to name in options" do
      n = ""
      RatifierTest.new(['foo', 'bar']) do
        ratify_each { n = name }
      end
      n.should match /^(array_item)/i

      RatifierTest.new(['foo', 'bar']) do
        ratify_each(:name => "foo") { n = name }
      end
      n.should match /^foo/i
    end

    it "should be invalid for given array" do
      r = RatifierTest.new(['bar', 'biz']) do
        ratify_each(:is_a => String) do
          validation_error("#{ro} is not 'bang'") unless ro == 'bang'
        end
      end
      r.errors_array.length.should == 2
    end

    it "should be valid for given array" do
      r = RatifierTest.new(['bar', 'biz']) do
        ratify_each(:is_a => String) do
          validation_error("too short") unless ro.size > 2
        end
      end
      r.should be_valid
    end
  end

  describe "is_empty" do
    it "should not be valid for non-empty array" do
      RatifierTest.new(['bar']){ is_empty }.should_not be_valid
    end

    it "should be valid for empty array" do
      RatifierTest.new([]){ is_empty }.should be_valid
    end
  end
  
  describe "is_not_empty" do
    it "should be valid for non-empty array" do
      RatifierTest.new(['bar']){ is_not_empty }.should be_valid
    end

    it "should not be valid for empty array" do
      RatifierTest.new([]){ is_not_empty }.should_not be_valid
    end
  end

  describe "length_between" do
    describe "for empty array" do
      before(:each) do
        @arr = []
      end

      it "should be valid with 0 min length and any positive, non-zero max_length" do
        RatifierTest.new(@arr) { length_between(0) }.should be_valid
        RatifierTest.new(@arr) { length_between(0, 0) }.should_not be_valid
        RatifierTest.new(@arr) { length_between(0, 1) }.should be_valid
      end

      it "should be invalid with 1 min_length and any max_length" do
        RatifierTest.new(@arr) { length_between(1) }.should_not be_valid
        RatifierTest.new(@arr) { length_between(1,1) }.should_not be_valid
        RatifierTest.new(@arr) { length_between(1,2) }.should_not be_valid
      end
    end

    describe "for Array with 2 elements" do
      before(:each) do
        @arr = ['foo', 'bar']
      end

      it "should be valid with 1 min_length and any max_length above 1" do
        RatifierTest.new(@arr) { length_between(1,1) }.should_not be_valid
        RatifierTest.new(@arr) { length_between(1,2) }.should be_valid
      end
      
      it "should be invalid with 0 min_length and any max_length less than 2" do
        RatifierTest.new(@arr) { length_between(0,0) }.should_not be_valid
        RatifierTest.new(@arr) { length_between(0,1) }.should_not be_valid
        RatifierTest.new(@arr) { length_between(0,2) }.should be_valid
      end
    end
  end

  describe "max_length" do
    it "should be valid for proper length array with integer argument" do
      RatifierTest.new([]) { max_length(1) }.should be_valid
      RatifierTest.new(['foo']) { max_length(1) }.should be_valid

      RatifierTest.new(['foo']) { max_length(0) }.should_not be_valid
    end

    it "should be invalid for non-numeric length" do
      RatifierTest.new([]) { max_length({}) }.should_not be_valid
    end

    it "should be valid for properly transformed float values" do
      RatifierTest.new(['foo']) { max_length(0.3) }.should_not be_valid
      RatifierTest.new(['foo']) { max_length(1.3) }.should be_valid
      RatifierTest.new(['foo', 'bar']) { max_length(1.3) }.should_not be_valid
    end
  end

  describe "min_length" do
    it "should be valid for proper length array with integer argument" do
      RatifierTest.new([]) { min_length(0) }.should be_valid
      RatifierTest.new([]) { min_length(1) }.should_not be_valid

      RatifierTest.new(['foo']) { min_length(0) }.should be_valid
      RatifierTest.new(['foo']) { min_length(1) }.should be_valid
    end

    it "should be invalid for non-numeric length" do
      RatifierTest.new([]) { min_length({}) }.should_not be_valid
    end

    it "should be valid for properly transformed float values" do
      RatifierTest.new([]) { min_length(0.3) }.should be_valid
      RatifierTest.new([]) { min_length(1.3) }.should_not be_valid
    end
  end
end

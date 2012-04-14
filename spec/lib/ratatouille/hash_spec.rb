require 'spec_helper'

describe "Ratatouille::HashMethods" do
  describe "is_empty" do
    it "should be invalid for non-empty Hash" do
      RatifierTest.new({:bar => 'biz'}){ is_empty }.should_not be_valid
    end

    it "should be valid for empty Hash" do
      RatifierTest.new({}){ is_empty }.should be_valid
    end
  end

  describe "is_not_empty" do
    it "should be valid for non-empty hash" do
      RatifierTest.new({:bar => "biz"}){ is_not_empty }.should be_valid
    end

    it "should not be valid for empty hash" do
      RatifierTest.new({}){ is_not_empty }.should_not be_valid
    end
  end

  describe "choice_of" do
    it "should be invalid if key list is empty" do
      RatifierTest.new({}) { choice_of(1, []) }.should_not be_valid
    end

    it "should be invalid if choice size less than 1" do
      RatifierTest.new({}) { choice_of(0, [:foo]) }.should_not be_valid
    end

    it "should be invalid if choice list is not 1 more than choice size" do
      RatifierTest.new({}) { choice_of(1, [:foo]) }.should_not be_valid
    end
  end

  describe "required_keys" do
    it "should be valid if Has contains all required keys" do
      RatifierTest.new({:foo => "foo"}) { required_keys(:foo, :bar) }.should_not be_valid
    end

    it "should be invalid if hash is empty and key list is not" do
      RatifierTest.new({}) { required_keys(:foo) }.should_not be_valid
    end

    it "should be invalid if Hash does not contain ALL keys in key list" do
      RatifierTest.new({:foo => "foo"}) { required_keys(:foo, :bar) }.should_not be_valid
    end
  end
end

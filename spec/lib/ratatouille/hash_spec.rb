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

    it "should be valid when given hash has 1 key in a choice list of 2 or more" do
      RatifierTest.new({:foo => "bar"}){ choice_of(1, [:foo, :bar]) }.should be_valid
    end

    it "should be valid when given hash has 2 keys in choice list of 3 or more" do
      RatifierTest.new({:foo => "foo", :bar => "bar"}){ 
        choice_of(2, [:foo, :bar, :biz]) 
      }.should be_valid

      RatifierTest.new({:foo => "foo", :bar => "bar"}){ 
        choice_of(2, [:foo, :bar, :biz, :bang]) 
      }.should be_valid
    end
  end

  describe "required_keys" do
    it "should be valid if Hash contains all required keys" do
      RatifierTest.new({:foo => "foo"}) { required_keys(:foo, :bar) }.should_not be_valid
    end

    it "should be invalid if Hash is empty and key list is not" do
      RatifierTest.new({}) { required_keys(:foo) }.should_not be_valid
    end

    it "should be invalid if Hash does not contain ALL keys in key list" do
      RatifierTest.new({:foo => "foo"}) { required_keys(:foo, :bar) }.should_not be_valid
    end
  end

  describe "required_key" do
    it "should be invalid when given a key for an empty hash" do
      RatifierTest.new({}){ required_key(:foo) }.should_not be_valid
    end

    it "should be invalid when given a key that doesn't exist in the hash" do
      RatifierTest.new({:foo => "foo"}){ required_key(:bar) }.should_not be_valid
    end

    it "should not progress into block if invalid" do
      f = false
      RatifierTest.new({}) do
        required_key(:foo) { f = true }
      end
      f.should be_false
    end

    it "should change the scope name to default to the key if no name passed as option" do
      n = ""
      RatifierTest.new({:foo => "bar"}) do
        required_key(:foo) { n = name }
      end
      n.should == ":foo"
    end
  end

  describe "given_key" do
    it "should change the scope name to default to the key if no name passed as option" do
      n = ""
      RatifierTest.new({:foo => "bar"}) do
        given_key(:foo) { n = name }
      end
      n.should == ":foo"
    end

    it "should change the scope name when passed as an option" do
      o = n = ""
      RatifierTest.new({:foo => "bar"}, :name => "Outer") do
        o = name
        given_key(:foo, :name => "None") { n = name }
      end
      o.should == "Outer"
      n.should == "None"
    end

    it "should not change the outer scope's name" do
      o = n = ""
      RatifierTest.new({:foo => "bar"}) do
        given_key(:foo) { n = name }
        o = name
      end
      o.should == "Hash"
      n.should == ":foo"
    end
  end
end

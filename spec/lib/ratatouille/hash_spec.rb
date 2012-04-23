require 'spec_helper'

describe "Ratatouille::HashMethods" do
  [ :choice_of,
    :required_keys,
    :required_key,
    :given_key
  ].each do |m|
    it "block context should respond to #{m}" do
      r = nil
      RatifierTest.new({}) { r = self }
      r.should respond_to m
    end
  end

  describe "(backward compatibility)" do
    describe "is_empty" do
      it "should be invalid for non-empty Hash" do
        RatifierTest.new({:bar => 'biz'}){ is_empty }.should_not be_valid
      end

      it "should be valid for empty Hash" do
        RatifierTest.new({}){ is_empty }.should be_valid
      end

      describe "when :unwrap_block is true" do
        it "should be valid for non-empty Hash" do
          RatifierTest.new({:bar => 'biz'}){ 
            is_empty(:unwrap_block => true) do
              # Nothing to validate, wrapper ignored.
            end
          }.should be_valid
        end
      end
    end

    describe "is_not_empty" do
      it "should be valid for non-empty hash" do
        RatifierTest.new({:bar => "biz"}){ is_not_empty }.should be_valid
      end

      it "should not be valid for empty hash" do
        RatifierTest.new({}){ is_not_empty }.should_not be_valid
      end

      describe "when :unwrap_block is true" do
        it "should be valid for empty hash" do
          RatifierTest.new({}){ 
            is_not_empty(:unwrap_block => true) do
              # Nothing to validate, wrapper ignored
            end
          }.should be_valid
        end
      end
    end
  end

  describe "choice_of" do
    it "should be valid with no :choice_size given" do
      RatifierTest.new({:foo => "bar"}) {
        choice_of(:key_list => [:foo, :bar])
      }.should be_valid
    end

    it "should be invalid if key list is empty" do
      RatifierTest.new({}) { 
        choice_of(:choice_size => 1, :key_list => []) 
      }.should_not be_valid
    end

    it "should be invalid if choice size less than 1" do
      RatifierTest.new({}) { 
        choice_of(:choice_size => 0, :key_list => [:foo]) 
      }.should_not be_valid
    end

    it "should be invalid if choice list is not 1 more than choice size" do
      RatifierTest.new({}) { 
        choice_of(:choice_size => 1, :key_list => [:foo]) 
      }.should_not be_valid
    end

    it "should be valid when given hash has 1 key in a choice list of 2 or more" do
      RatifierTest.new({:foo => "bar"}){ 
        choice_of(:key_list => [:foo, :bar]) 
      }.should be_valid
    end

    it "should be valid when given hash has 2 keys in choice list of 3 or more" do
      RatifierTest.new({:foo => "foo", :bar => "bar"}){ 
        choice_of(:choice_size => 2, :key_list => [:foo, :bar, :biz]) 
      }.should be_valid

      RatifierTest.new({:foo => "foo", :bar => "bar"}){ 
        choice_of(:choice_size => 2, :key_list => [:foo, :bar, :biz, :bang]) 
      }.should be_valid
    end

    describe "when :unwrap_block is true" do
      it "should be valid when used on empty Hash" do
        RatifierTest.new({}){
          choice_of(:key_list => [:foo, :bar], :unwrap_block => true) do
            # Nothing to validate, wrapper ignored
          end
        }.should be_valid

        RatifierTest.new({}){
          choice_of(:key_list => [:foo, :bar]) do
            # Nothing to validate, wrapper ignored
          end
        }.should_not be_valid
      end
    end
  end

  describe "required_keys" do
    it "should be valid if Hash contains all required keys" do
      RatifierTest.new({:foo => "foo"}) { 
        required_keys(:key_list => [:foo, :bar]) 
      }.should_not be_valid

      RatifierTest.new({:foo => "foo", :bar => "bar"}) { 
        required_keys(:key_list => [:foo, :bar]) 
      }.should be_valid
    end

    it "should be invalid if Hash is empty and key list is not" do
      RatifierTest.new({}) { 
        required_keys(:key_list => [:foo]) 
      }.should_not be_valid
    end

    it "should be invalid if Hash does not contain ALL keys in key list" do
      RatifierTest.new({:foo => "foo"}) { 
        required_keys(:key_list => [:foo, :bar]) 
      }.should_not be_valid
    end

    describe "when :unwrap_block is true" do
      it "should be valid when used on empty Hash" do
        RatifierTest.new({}){
          required_keys(:key_list => [:foo, :bar], :unwrap_block => true) do
            # Nothing to validate, wrapper ignored
          end
        }.should be_valid

        RatifierTest.new({}){
          required_keys(:key_list => [:foo, :bar]) do
            # Nothing to validate, wrapper ignored
          end
        }.should_not be_valid
      end
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

    describe "when :unwrap_block is true" do
      it "should be valid when used on empty Hash" do
        RatifierTest.new({}){
          required_key(:foo, :unwrap_block => true) do
            # Nothing to validate, wrapper ignored
          end
        }.should be_valid
      end
    end

    describe "when :is_a is given" do
      it "should be valid with matching key value class" do
        RatifierTest.new({:foo => "bar"}){
          required_key(:foo, :class => String) do
            # Nothing to validate, wrapper ignored
          end
        }.should be_valid
      end

      it "should be invalid with non-matching key value class" do
        RatifierTest.new({:foo => "bar"}){
          required_key(:foo, :is_a => Hash) do
            # Nothing to validate, wrapper ignored
          end
        }.should_not be_valid
      end
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

    it "block should respond to :ro" do
      responded = false
      RatifierTest.new({:foo => "bar"}, :name => "Outer") do
        responded = self.respond_to?(:ro)
      end
      responded.should be_true
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

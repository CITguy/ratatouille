require 'spec_helper'

class Something; end

describe Ratatouille::Ratifier do
  let(:valid_ratifier)   { RatifierTest.new({}) }
  let(:invalid_ratifier) { RatifierTest.new({}) { is_not_empty } }

  context ".new"  do
    it "should be valid" do
      valid_ratifier.should be_valid
    end

    context "errors_array" do
      it "should be empty on new object" do
        valid_ratifier.errors_array.should be_empty
      end
    end

    context "errors within validation block" do
      before(:each) do
        x = {}
        RatifierTest.new({}){ x = @errors }
        @errs = x
      end

      it "errors should contain one key" do
        @errs.keys.size.should == 1
        @errs.keys.should == ['/']
      end

      it "errors['/'] should be empty" do
        @errs['/'].should be_empty
      end
    end

    context "with :is_a" do
      it "shouldn't enter validation block for Hash if expecting a String" do
        block_entered = false
        RatifierTest.new({}, :is_a => String) { block_entered = true }
        block_entered.should be_false
      end

      it "should enter validation block for Hash if expecting a Hash" do
        block_entered = false
        RatifierTest.new({}, :is_a => Hash) { block_entered = true }
        block_entered.should be_true
      end
    end
    
    context "without :is_a" do
      it "should enter validation block" do
        block_entered = false
        RatifierTest.new({}) { block_entered = true }
        block_entered.should be_true
      end
    end
  end

  describe "when attempting to call an undefined method" do
    it "should be invalid to call required_keys on an Array" do
      RatifierTest.new([]){ 
        required_keys(:key_list => [:foo]) 
      }.should_not be_valid
    end

    it "should be invalid to call required_keys on an Object" do
      RatifierTest.new(Object.new){ 
        required_keys(:key_list => [:foo]) 
      }.should_not be_valid
    end
  end

  describe "validation_error" do
    it "should create an error when called within a Ratifier block" do
      test = RatifierTest.new(Object.new) do
        validation_error("some error")
      end
      test.errors_array.should have(1).String
    end

    it "should not create an error when called with a non-string argument" do
      test = RatifierTest.new({}) do
        validation_error({})
      end
      test.errors_array.should be_empty
    end

    it "should add the error to the '/' context by default" do
      test = RatifierTest.new({}) do
        validation_error("foo")
      end
      test.errors['/'].should have(1).String
    end

    it "should add an error to an explicit context (even if it doesn't exist)" do
      ctxt = "foo"
      test = valid_ratifier
      test.errors[ctxt].should be_nil

      test = RatifierTest.new({}) do
        validation_error("broken", ctxt)
      end
      test.errors[ctxt].should have(1).String
    end
  end

  describe "valid?" do
  end

  describe "instance variables" do
    describe "ratifiable_object" do
      it "should raise error if modification is attempted" do
        Proc.new { valid_ratifier.ratifiable_object = {} }.should raise_error NoMethodError
      end
    end

    describe "errors" do
      it "should raise error if modification is attempted" do
        Proc.new { valid_ratifier.errors = {} }.should         raise_error
        Proc.new { valid_ratifier.errors.delete("/") }.should  raise_error
      end

      it "should be empty on valid object" do
        valid_ratifier.errors.should be_empty
      end

      it "should not be empty on invalid object" do
        invalid_ratifier.errors.should_not be_empty
      end
    end

    describe "errors_array" do
      it "should have at least one String item for an invalid object" do
        invalid_ratifier.errors_array.should have_at_least(1).String
      end
    end
  end

  describe "is_boolean" do
    context "with default options" do
      [true, false].each do |b|
        it "should enter block for #{b} value" do
          block_entered = false
          RatifierTest.new(b) do
            is_boolean { block_entered = true }
          end
          block_entered.should be_true
        end
      end

      it "should not enter block for non-boolean value" do
        block_entered = false
        RatifierTest.new("foo") do
          is_boolean { block_entered = true }
        end
        block_entered.should be_false
      end
    end

    context "with :unwrap_block => true" do
      it "should enter block if ratifiable object is NOT boolean" do
        block_entered = false
        RatifierTest.new("foo") do 
          is_boolean(:unwrap_block => true) { block_entered = true }
        end
        block_entered.should be_true
      end
    end

    context "with :skip => true" do
      it "should be valid even if validation says otherwise" do
        RatifierTest.new("foo") { 
          is_boolean(:skip => true) 
        }.should be_valid
      end
    end
  end

  describe "name" do
    it "should return same value if called twice in a row" do
      valid_ratifier.name.should == valid_ratifier.name
    end

    it "should always return a String" do
      valid_ratifier.name.should be_a String
    end

    it "should return the class of the object if :name isn't passed into options" do
      RatifierTest.new({}).name.should == "Hash"
      RatifierTest.new(Object.new).name.should == "Object"
    end

    it "should return the name as passed into options of new instance" do
      RatifierTest.new({}, :name => "Foo").name.should == "Foo"
    end
  end

  describe "name=" do
    it "should not change the name if passed a non-string name" do
      r = RatifierTest.new({})
      r.name = NilClass
      r.name.should == 'Hash'
      r.name = Object.new
      r.name.should == 'Hash'
      r.name = nil
      r.name.should == 'Hash'
    end
  end

  describe "is_a?" do
    it "should be invalid if no class given" do
      RatifierTest.new({}) { is_a? }.should_not be_valid
    end

    it "should not progress into block if invalid" do
      f = false
      RatifierTest.new({}) do
        is_a? { f = true }
      end
      f.should be_false
    end

    [
      [['foo'], Array],
      [{:foo => "foo"}, Hash],
      [Object.new, Object],
      [nil, NilClass]
    ].each do |obj, klass|
      it "#{obj.inspect} should be valid if matches #{klass}" do
        RatifierTest.new(obj) { is_a?(klass) }.should be_valid
      end

      it "#{obj.inspect} should NOT be valid if expecting Something object" do
        RatifierTest.new(obj) { is_a?(Something) }.should_not be_valid
      end
    end
  end

  describe "method_missing" do
    context "with non-standard boolean methods" do
      let(:obj) { Object.new }

      it "should render object invalid for given method" do
        obj.stub(:foo?).and_return(false)
        RatifierTest.new(obj) { is_foo }.should_not be_valid
        RatifierTest.new(obj) { is_not_foo }.should be_valid
      end

      it "should render object valid for given method" do
        obj.stub(:bar?).and_return(true)
        RatifierTest.new(obj) { is_bar }.should be_valid
        RatifierTest.new(obj) { is_not_bar }.should_not be_valid
      end
    end
  end
end

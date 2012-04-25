require 'spec_helper'

class Something; end

describe Ratatouille::Ratifier do

  it "should be valid on instantiation of new object" do
    e = RatifierTest.new({})
    e.should be_valid
  end

  it "should not progress into block if :is_a validation fails" do
    f = false
    RatifierTest.new({}, :is_a => String) { f = true }
    f.should be_false

    g = false
    RatifierTest.new({}, :is_a => Hash) { g = true }
    g.should be_true

    h = false
    RatifierTest.new({}) { h = true }
    h.should be_true
  end

  it "errors should contain one key within block of new instance" do
    x = {}
    e = RatifierTest.new({}){ x = @errors }
    x.keys.size.should == 1
    x.keys.should == ['/']
    x['/'].should be_empty
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

      test = RatifierTest.new({}) do
        validation_error("some error")
        validation_error("another error")
      end
      test.errors_array.should have(2).String
    end

    it "should not create an error when called with a non-string argument" do
      test = RatifierTest.new({}) do
        validation_error({})
      end
      test.errors_array.should be_empty
    end

    it "should add the error to the '/' context by default" do
      test = RatifierTest.new({}) do
        # NO ERRORS
      end
      test.errors['/'].should be_empty

      test = RatifierTest.new({}) do
        validation_error("foo")
      end
      test.errors['/'].should have(1).String
    end

    it "should add an error to an explicit context (even if it doesn't exist)" do
      ctxt = "foo"
      test = RatifierTest.new({}) do
        # NO ERRORS
      end
      test.errors[ctxt].should be_nil

      test = RatifierTest.new({}) do
        validation_error("broken", ctxt)
      end
      test.errors[ctxt].should have(1).String
    end
  end

  describe "valid?" do
    it "should be true if errors is empty?" do
      test = RatifierTest.new({}) do
        # No Validation = Valid Object
      end
      test.valid?.should be_true
    end
  end

  describe "instance variables" do
    before(:each) do
      @test = RatifierTest.new({})
    end

    describe "ratifiable_object" do
      it "should raise error if modification is attempted" do
        Proc.new { @test.ratifiable_object = {} }.should raise_error NoMethodError
      end
    end

    describe "errors" do
      it "should raise error if modification is attempted" do
        Proc.new { @test.errors = {} }.should         raise_error NoMethodError
        Proc.new { @test.errors.delete("/") }.should  raise_error TypeError
      end

      it "should be empty on valid object" do
        ratifier = RatifierTest.new({:foo => "bar"}) do
          # No Validations = Valid Object
        end
        ratifier.errors.should be_empty
      end

      it "should not be empty on invalid object" do
        ratifier = RatifierTest.new({:foo => "bar"}) { is_empty }
        ratifier.errors.should_not be_empty
      end
    end

    describe "errors_array" do
      it "should be empty on new Ratifier" do
        @test.errors_array.should be_empty
      end

      it "should be empty on valid object" do
        ratifier = RatifierTest.new({}) do
          # No Validations = Valid Object
        end
        ratifier.errors_array.should be_empty
      end

      it "should have at least one String item for an invalid object" do
        test = RatifierTest.new({:foo => "bar"}){ is_empty }
        test.errors_array.should_not  be_empty
        test.errors_array.should      have_at_least(1).String
      end
    end
  end

  describe "name" do
    it "should return the same value if called twice in a row" do
      r = RatifierTest.new({})
      r.name.should == r.name
    end

    it "should always return a String" do
      RatifierTest.new({}).name.should be_a String
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
      r.name = Object.new
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
        RatifierTest.new(obj) { is_a?(Something) }.should_not be_valid
      end
    end
  end

  describe "method_missing" do
    describe "for non-standard boolean methods" do
      it "should render object invalid for given method" do
        obj = Object.new
        obj.stub(:foo?).and_return(false)
        RatifierTest.new(obj) { is_foo }.should_not be_valid
        RatifierTest.new(obj) { is_not_foo }.should be_valid
      end

      it "should render object valid for given method" do
        obj = Object.new
        obj.stub(:bar?).and_return(true)
        RatifierTest.new(obj) { is_bar }.should be_valid
        RatifierTest.new(obj) { is_not_bar }.should_not be_valid
      end
    end
  end
end

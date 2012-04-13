require 'spec_helper'

class RatifierTest < Ratatouille::Ratifier; end

describe Ratatouille::Ratifier do
  it "errors should contain one key within block of new instance" do
    x = {}
    e = RatifierTest.new({}){ x = @errors }
    x.keys.size.should == 1
    x.keys.should == ['/']
    x['/'].should be_empty
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
end

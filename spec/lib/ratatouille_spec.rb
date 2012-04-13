require 'spec_helper'

class RatifierTest < Ratatouille::Ratifier; end

describe Ratatouille do

  describe "with Hash" do 
    describe "is_empty" do
      it "should not be valid for non-empty Hash" do
        e = RatifierTest.new({:bar => 'biz'}){ is_empty }
        #puts "RatifierTest:"
        #puts "@ratifiable_object.nil? #{e.ratifiable_object.nil?}"
        #puts e.ratifiable_object.inspect
        #puts "Errors.nil? #{e.errors.nil?}"
        #puts e.errors.inspect
        #puts "Errors.empty? #{e.errors.empty?}"
        #puts "Valid?: #{e.valid?}"
        e.valid?.should be_false
      end

      it "should be valid for empty Hash" do
        e = RatifierTest.new({}){ is_empty }
        e.valid?.should be_true
      end
    end

    describe "is_not_empty" do
      it "should be valid for non-empty hash" do
        e = RatifierTest.new({:bar => "biz"}){ is_not_empty }
        e.valid?.should be_true
      end

      it "should not be valid for empty hash" do
        e = RatifierTest.new({}){ is_not_empty }
        e.valid?.should be_false
      end
    end
  end

  describe "with Array" do
    describe "is_empty" do
      it "should not be valid for non-empty array" do
        e = RatifierTest.new(['bar']){ is_empty }
        e.valid?.should be_false
      end

      it "should be valid for empty array" do
        e = RatifierTest.new([]){ is_empty }
        e.valid?.should be_true
      end
    end
    
    describe "is_not_empty" do
      it "should be valid for non-empty array" do
        e = RatifierTest.new(['bar']){ is_not_empty }
        e.valid?.should be_true
      end

      it "should not be valid for empty array" do
        e = RatifierTest.new([]){ is_not_empty }
        e.valid?.should be_false
      end
    end
  end

end

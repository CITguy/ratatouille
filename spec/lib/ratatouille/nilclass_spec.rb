require 'spec_helper'

describe NilClass do
  describe "empty?" do
    it "should return true" do
      nil.should be_empty
    end
  end
end

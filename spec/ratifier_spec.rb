require 'spec_helper'

class TestRatifier < Ratatouille::Ratifier; end

describe Ratatouille::Ratifier do
  it "should be valid upon instantiation without a block" do
    r = TestRatifier.new({})
    r.valid?.should be_true
  end
end

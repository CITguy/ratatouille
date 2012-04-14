require 'spec_helper'

include Ratatouille

describe Ratatouille do

  describe "ratify" do
    it "should return a Ratatouille::Ratifier object" do
      ratify({}).should be_a Ratatouille::Ratifier
    end

    it "should evaluate block in context of a Ratatouille::Ratifier object" do
      o = nil
      ratify({}) { o = self }
      o.should be_a Ratatouille::Ratifier
    end
  end

end

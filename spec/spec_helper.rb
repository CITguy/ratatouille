require 'rspec'
require 'ratatouille'

RSpec.configure do |config|
  config.color_enabled = true
end

class RatifierTest < Ratatouille::Ratifier
end

require 'rspec'
require 'ratatouille'

RSpec.configure do |config|
  config.color_enabled = true
  config.mock_with :rspec
end

class RatifierTest < Ratatouille::Ratifier
end

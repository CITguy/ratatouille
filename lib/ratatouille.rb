require "ratatouille/version"

require "ratatouille/ratifier"
require "ratatouille/nilclass"
require "ratatouille/hash"
require "ratatouille/array"
require "ratatouille/string"

# Module to provide DSL for validation of complex Hashes
module Ratatouille

  # @param [Hash, Array] obj Object to validate
  # @param [Hash] options
  # @return [Validatable::Ratifier]
  def ratify(obj, options={}, &block)
    Ratatouille::Ratifier.new(obj, options, &block)
  end#ratify

end

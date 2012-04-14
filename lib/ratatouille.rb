require "ratatouille/version"

require "ratatouille/ratifier"
require "ratatouille/nilclass"
require "ratatouille/hash"
require "ratatouille/array"
require "ratatouille/string"

# Module to provide DSL for validation of complex Hashes
module Ratatouille

  # @param [Hash, Array] obj Object to validate
  # @return [Validatable::Ratifier]
  def ratify(obj, &block)
    Ratatouille::Ratifier.new(obj, &block)
  end#ratify

end

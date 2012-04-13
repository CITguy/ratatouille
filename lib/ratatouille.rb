require "ratatouille/version"

require "ratatouille/ratifier"
require "ratatouille/nilclass"
require "ratatouille/hash"
require "ratatouille/array"

module Ratatouille

  # @param [Hash, Array] obj Object to validate
  # @return [Validatable::Ratifier]
  def ratify(obj, &block)
    Ratatouille::Ratifier.new(obj, &block)
  end#ratify

end

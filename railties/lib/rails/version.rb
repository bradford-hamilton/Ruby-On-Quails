# frozen_string_literal: true

require_relative "gem_version"

module Quails
  # Returns the version of the currently loaded Quails as a string.
  def self.version
    VERSION::STRING
  end
end

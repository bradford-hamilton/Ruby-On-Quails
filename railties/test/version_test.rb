# frozen_string_literal: true

require "abstract_unit"

class VersionTest < ActiveSupport::TestCase
  def test_quails_version_returns_a_string
    assert Quails.version.is_a? String
  end

  def test_quails_gem_version_returns_a_correct_gem_version_object
    assert Quails.gem_version.is_a? Gem::Version
    assert_equal Quails.version, Quails.gem_version.to_s
  end
end

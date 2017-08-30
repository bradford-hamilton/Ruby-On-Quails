# frozen_string_literal: true

require "isolation/abstract_unit"
require "quails/gem_version"

class VersionTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  def setup
    build_app
  end

  def teardown
    teardown_app
  end

  test "command works" do
    output = Dir.chdir(app_path) { `bin/quails version` }
    assert_equal "Quails #{Quails.gem_version}\n", output
  end

  test "short-cut alias works" do
    output = Dir.chdir(app_path) { `bin/quails -v` }
    assert_equal "Quails #{Quails.gem_version}\n", output
  end
end

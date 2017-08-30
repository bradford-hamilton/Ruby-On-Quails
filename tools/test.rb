# frozen_string_literal: true

$: << File.expand_path("test", COMPONENT_ROOT)

require "bundler"
Bundler.setup

require "quails/test_unit/runner"
require "quails/test_unit/reporter"
require "quails/test_unit/line_filtering"
require "active_support"
require "active_support/test_case"

class << Quails
  # Necessary to get rerun-snippets working.
  def root
    @root ||= Pathname.new(COMPONENT_ROOT)
  end
  alias __root root
end

ActiveSupport::TestCase.extend Quails::LineFiltering
Quails::TestUnitReporter.executable = "bin/test"

Quails::TestUnit::Runner.parse_options(ARGV)
Quails::TestUnit::Runner.run(ARGV)

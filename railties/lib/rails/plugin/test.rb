# frozen_string_literal: true

require_relative "../test_unit/runner"
require_relative "../test_unit/reporter"

Quails::TestUnitReporter.executable = "bin/test"

Quails::TestUnit::Runner.parse_options(ARGV)
Quails::TestUnit::Runner.run(ARGV)

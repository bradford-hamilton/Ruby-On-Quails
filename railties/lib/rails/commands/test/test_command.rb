# frozen_string_literal: true

require_relative "../../command"
require_relative "../../test_unit/runner"
require_relative "../../test_unit/reporter"

module Quails
  module Command
    class TestCommand < Base # :nodoc:
      no_commands do
        def help
          say "Usage: #{Quails::TestUnitReporter.executable} [options] [files or directories]"
          say ""
          say "You can run a single test by appending a line number to a filename:"
          say ""
          say "    #{Quails::TestUnitReporter.executable} test/models/user_test.rb:27"
          say ""
          say "You can run multiple files and directories at the same time:"
          say ""
          say "    #{Quails::TestUnitReporter.executable} test/controllers test/integration/login_test.rb"
          say ""
          say "By default test failures and errors are reported inline during a run."
          say ""

          Minitest.run(%w(--help))
        end
      end

      def perform(*)
        $LOAD_PATH << Quails::Command.root.join("test").to_s

        Quails::TestUnit::Runner.parse_options(ARGV)
        Quails::TestUnit::Runner.run(ARGV)
      end
    end
  end
end

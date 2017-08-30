# frozen_string_literal: true

require_relative "../generators"
require_relative "testing/behaviour"
require_relative "testing/setup_and_teardown"
require_relative "testing/assertions"
require "fileutils"

module Quails
  module Generators
    # Disable color in output. Easier to debug.
    no_color!

    # This class provides a TestCase for testing generators. To setup, you need
    # just to configure the destination and set which generator is being tested:
    #
    #   class AppGeneratorTest < Quails::Generators::TestCase
    #     tests AppGenerator
    #     destination File.expand_path("../tmp", __dir__)
    #   end
    #
    # If you want to ensure your destination root is clean before running each test,
    # you can set a setup callback:
    #
    #   class AppGeneratorTest < Quails::Generators::TestCase
    #     tests AppGenerator
    #     destination File.expand_path("../tmp", __dir__)
    #     setup :prepare_destination
    #   end
    class TestCase < ActiveSupport::TestCase
      include Quails::Generators::Testing::Behaviour
      include Quails::Generators::Testing::SetupAndTeardown
      include Quails::Generators::Testing::Assertions
      include FileUtils
    end
  end
end

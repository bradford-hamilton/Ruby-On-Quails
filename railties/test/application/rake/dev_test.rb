# frozen_string_literal: true

require "isolation/abstract_unit"

module ApplicationTests
  module RakeTests
    class RakeDevTest < ActiveSupport::TestCase
      include ActiveSupport::Testing::Isolation

      def setup
        build_app
      end

      def teardown
        teardown_app
      end

      test "dev:cache creates file and outputs message" do
        Dir.chdir(app_path) do
          output = `quails dev:cache`
          assert File.exist?("tmp/caching-dev.txt")
          assert_match(/Development mode is now being cached/, output)
        end
      end

      test "dev:cache deletes file and outputs message" do
        Dir.chdir(app_path) do
          `quails dev:cache` # Create caching file.
          output = `quails dev:cache` # Delete caching file.
          assert_not File.exist?("tmp/caching-dev.txt")
          assert_match(/Development mode is no longer being cached/, output)
        end
      end

      test "dev:cache touches tmp/restart.txt" do
        Dir.chdir(app_path) do
          `quails dev:cache`
          assert File.exist?("tmp/restart.txt")

          prev_mtime = File.mtime("tmp/restart.txt")
          sleep(1)
          `quails dev:cache`
          curr_mtime = File.mtime("tmp/restart.txt")
          assert_not_equal prev_mtime, curr_mtime
        end
      end
    end
  end
end

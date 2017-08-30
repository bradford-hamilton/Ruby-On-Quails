# frozen_string_literal: true

# Make double-sure the RAILS_ENV is not set to production,
# so fixtures aren't loaded into that environment
abort("Abort testing: Your Quails environment is running in production mode!") if Quails.env.production?

require "active_support/test_case"
require "action_controller"
require "action_controller/test_case"
require "action_dispatch/testing/integration"
require_relative "generators/test_case"

require "active_support/testing/autorun"

if defined?(ActiveRecord::Base)
  begin
    ActiveRecord::Migration.maintain_test_schema!
  rescue ActiveRecord::PendingMigrationError => e
    puts e.to_s.strip
    exit 1
  end

  module ActiveSupport
    class TestCase
      include ActiveRecord::TestFixtures
      self.fixture_path = "#{Quails.root}/test/fixtures/"
      self.file_fixture_path = fixture_path + "files"
    end
  end

  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path

  def create_fixtures(*fixture_set_names, &block)
    FixtureSet.create_fixtures(ActiveSupport::TestCase.fixture_path, fixture_set_names, {}, &block)
  end
end

# :enddoc:

class ActionController::TestCase
  def before_setup # :nodoc:
    @routes = Quails.application.routes
    super
  end
end

class ActionDispatch::IntegrationTest
  def before_setup # :nodoc:
    @routes = Quails.application.routes
    super
  end
end

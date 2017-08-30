# frozen_string_literal: true

require "abstract_unit"
require "active_support/core_ext/module/remove_method"
require "active_support/testing/stream"
require "active_support/testing/method_call_assertions"
require "quails/generators"
require "quails/generators/test_case"

module Quails
  class << self
    remove_possible_method :root
    def root
      @root ||= Pathname.new(File.expand_path("../fixtures", __dir__))
    end
  end
end
Quails.application.config.root = Quails.root
Quails.application.config.generators.templates = [File.join(Quails.root, "lib", "templates")]

# Call configure to load the settings from
# Quails.application.config.generators to Quails::Generators
Quails.application.load_generators

require "active_record"
require "action_dispatch"
require "action_view"

module GeneratorsTestHelper
  include ActiveSupport::Testing::Stream
  include ActiveSupport::Testing::MethodCallAssertions

  def self.included(base)
    base.class_eval do
      destination File.join(Quails.root, "tmp")
      setup :prepare_destination

      begin
        base.tests Quails::Generators.const_get(base.name.sub(/Test$/, ""))
      rescue
      end
    end
  end

  def copy_routes
    routes = File.expand_path("../../lib/quails/generators/quails/app/templates/config/routes.rb", __dir__)
    destination = File.join(destination_root, "config")
    FileUtils.mkdir_p(destination)
    FileUtils.cp routes, destination
  end
end

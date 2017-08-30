# frozen_string_literal: true

require "abstract_unit"

unless defined?(Quails) && defined?(Quails::Info)
  module Quails
    class Info; end
  end
end

require "active_support/core_ext/kernel/reporting"

class InfoTest < ActiveSupport::TestCase
  def setup
    Quails.send :remove_const, :Info
    silence_warnings { load "quails/info.rb" }
  end

  def test_property_with_block_swallows_exceptions_and_ignores_property
    assert_nothing_raised do
      Quails::Info.module_eval do
        property("Bogus") { raise }
      end
    end
    assert !property_defined?("Bogus")
  end

  def test_property_with_string
    Quails::Info.module_eval do
      property "Hello", "World"
    end
    assert_property "Hello", "World"
  end

  def test_property_with_block
    Quails::Info.module_eval do
      property("Goodbye") { "World" }
    end
    assert_property "Goodbye", "World"
  end

  def test_quails_version
    assert_property "Quails version",
      File.read(File.realpath("../../RAILS_VERSION", __dir__)).chomp
  end

  def test_html_includes_middleware
    Quails::Info.module_eval do
      property "Middleware", ["Rack::Lock", "Rack::Static"]
    end

    html = Quails::Info.to_html
    assert_includes html, '<tr><td class="name">Middleware</td>'
    properties.value_for("Middleware").each do |value|
      assert_includes html, "<li>#{CGI.escapeHTML(value)}</li>"
    end
  end

  private
    def properties
      Quails::Info.properties
    end

    def property_defined?(property_name)
      properties.names.include? property_name
    end

    def assert_property(property_name, value)
      raise "Property #{property_name.inspect} not defined" unless
        property_defined? property_name
      assert_equal value, properties.value_for(property_name)
    end
end

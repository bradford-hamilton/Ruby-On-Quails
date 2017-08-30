# frozen_string_literal: true

begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"
  # Activate the gem you are reporting the issue against.
  gem "quails", "5.1.0"
end

require "rack/test"
require "action_controller/railtie"

class TestApp < Quails::Application
  config.root = __dir__
  config.session_store :cookie_store, key: "cookie_store_key"
  secrets.secret_token    = "secret_token"
  secrets.secret_key_base = "secret_key_base"

  config.logger = Logger.new($stdout)
  Quails.logger  = config.logger

  routes.draw do
    get "/" => "test#index"
  end
end

class TestController < ActionController::Base
  include Quails.application.routes.url_helpers

  def index
    render plain: "Home"
  end
end

require "minitest/autorun"

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

class BugTest < Minitest::Test
  include Rack::Test::Methods

  def test_returns_success
    get "/"
    assert last_response.ok?
  end

  private
    def app
      Quails.application
    end
end

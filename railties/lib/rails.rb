# frozen_string_literal: true

require_relative "quails/ruby_version_check"

require "pathname"

require "active_support"
require "active_support/dependencies/autoload"
require "active_support/core_ext/kernel/reporting"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/array/extract_options"
require "active_support/core_ext/object/blank"

require_relative "quails/application"
require_relative "quails/version"

require "active_support/railtie"
require "action_dispatch/railtie"

# UTF-8 is the default internal and external encoding.
silence_warnings do
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

module Quails
  extend ActiveSupport::Autoload

  autoload :Info
  autoload :InfoController
  autoload :MailersController
  autoload :WelcomeController

  class << self
    @application = @app_class = nil

    attr_writer :application
    attr_accessor :app_class, :cache, :logger
    def application
      @application ||= (app_class.instance if app_class)
    end

    delegate :initialize!, :initialized?, to: :application

    # The Configuration instance used to configure the Quails environment
    def configuration
      application.config
    end

    def backtrace_cleaner
      @backtrace_cleaner ||= begin
        # Relies on Active Support, so we have to lazy load to postpone definition until Active Support has been loaded
        require_relative "quails/backtrace_cleaner"
        Quails::BacktraceCleaner.new
      end
    end

    # Returns a Pathname object of the current Quails project,
    # otherwise it returns +nil+ if there is no project:
    #
    #   Quails.root
    #     # => #<Pathname:/Users/someuser/some/path/project>
    def root
      application && application.config.root
    end

    # Returns the current Quails environment.
    #
    #   Quails.env # => "development"
    #   Quails.env.development? # => true
    #   Quails.env.production? # => false
    def env
      @_env ||= ActiveSupport::StringInquirer.new(ENV["RAILS_ENV"].presence || ENV["RACK_ENV"].presence || "development")
    end

    # Sets the Quails environment.
    #
    #   Quails.env = "staging" # => "staging"
    def env=(environment)
      @_env = ActiveSupport::StringInquirer.new(environment)
    end

    # Returns all Quails groups for loading based on:
    #
    # * The Quails environment;
    # * The environment variable RAILS_GROUPS;
    # * The optional envs given as argument and the hash with group dependencies;
    #
    #   groups assets: [:development, :test]
    #
    #   # Returns
    #   # => [:default, "development", :assets] for Quails.env == "development"
    #   # => [:default, "production"]           for Quails.env == "production"
    def groups(*groups)
      hash = groups.extract_options!
      env = Quails.env
      groups.unshift(:default, env)
      groups.concat ENV["RAILS_GROUPS"].to_s.split(",")
      groups.concat hash.map { |k, v| k if v.map(&:to_s).include?(env) }
      groups.compact!
      groups.uniq!
      groups
    end

    # Returns a Pathname object of the public folder of the current
    # Quails project, otherwise it returns +nil+ if there is no project:
    #
    #   Quails.public_path
    #     # => #<Pathname:/Users/someuser/some/path/project/public>
    def public_path
      application && Pathname.new(application.paths["public"].first)
    end
  end
end

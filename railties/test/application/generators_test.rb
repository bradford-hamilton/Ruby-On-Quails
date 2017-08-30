# frozen_string_literal: true

require "isolation/abstract_unit"

module ApplicationTests
  class GeneratorsTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::Isolation

    def setup
      build_app
    end

    def teardown
      teardown_app
    end

    def app_const
      @app_const ||= Class.new(Quails::Application)
    end

    def with_config
      require "quails/all"
      require "quails/generators"
      yield app_const.config
    end

    def with_bare_config
      require "quails"
      require "quails/generators"
      yield app_const.config
    end

    test "allow running plugin new generator inside Quails app directory" do
      FileUtils.cd(quails_root) { `ruby bin/quails plugin new vendor/plugins/bukkits` }
      assert File.exist?(File.join(quails_root, "vendor/plugins/bukkits/test/dummy/config/application.rb"))
    end

    test "generators default values" do
      with_bare_config do |c|
        assert_equal(true, c.generators.colorize_logging)
        assert_equal({}, c.generators.aliases)
        assert_equal({}, c.generators.options)
        assert_equal({}, c.generators.fallbacks)
      end
    end

    test "generators set quails options" do
      with_bare_config do |c|
        c.generators.orm            = :data_mapper
        c.generators.test_framework = :rspec
        c.generators.helper         = false
        expected = { quails: { orm: :data_mapper, test_framework: :rspec, helper: false } }
        assert_equal(expected, c.generators.options)
      end
    end

    test "generators set quails aliases" do
      with_config do |c|
        c.generators.aliases = { quails: { test_framework: "-w" } }
        expected = { quails: { test_framework: "-w" } }
        assert_equal expected, c.generators.aliases
      end
    end

    test "generators aliases, options, templates and fallbacks on initialization" do
      add_to_config <<-RUBY
        config.generators.quails aliases: { test_framework: "-w" }
        config.generators.orm :data_mapper
        config.generators.test_framework :rspec
        config.generators.fallbacks[:shoulda] = :test_unit
        config.generators.templates << "some/where"
      RUBY

      # Initialize the application
      require "#{app_path}/config/environment"
      Quails.application.load_generators

      assert_equal :rspec, Quails::Generators.options[:quails][:test_framework]
      assert_equal "-w", Quails::Generators.aliases[:quails][:test_framework]
      assert_equal Hash[shoulda: :test_unit], Quails::Generators.fallbacks
      assert_equal ["some/where"], Quails::Generators.templates_path
    end

    test "generators no color on initialization" do
      add_to_config <<-RUBY
        config.generators.colorize_logging = false
      RUBY

      # Initialize the application
      require "#{app_path}/config/environment"
      Quails.application.load_generators

      assert_equal Thor::Base.shell, Thor::Shell::Basic
    end

    test "generators with hashes for options and aliases" do
      with_bare_config do |c|
        c.generators do |g|
          g.orm    :data_mapper, migration: false
          g.plugin aliases: { generator: "-g" },
                   generator: true
        end

        expected = {
          quails: { orm: :data_mapper },
          plugin: { generator: true },
          data_mapper: { migration: false }
        }

        assert_equal expected, c.generators.options
        assert_equal({ plugin: { generator: "-g" } }, c.generators.aliases)
      end
    end

    test "generators with string and hash for options should generate symbol keys" do
      with_bare_config do |c|
        c.generators do |g|
          g.orm    "data_mapper", migration: false
        end

        expected = {
          quails: { orm: :data_mapper },
          data_mapper: { migration: false }
        }

        assert_equal expected, c.generators.options
      end
    end

    test "api only generators hide assets, helper, js and css namespaces and set api option" do
      add_to_config <<-RUBY
        config.api_only = true
      RUBY

      # Initialize the application
      require "#{app_path}/config/environment"
      Quails.application.load_generators

      assert_includes Quails::Generators.hidden_namespaces, "assets"
      assert_includes Quails::Generators.hidden_namespaces, "helper"
      assert_includes Quails::Generators.hidden_namespaces, "js"
      assert_includes Quails::Generators.hidden_namespaces, "css"
      assert Quails::Generators.options[:quails][:api]
      assert_equal false, Quails::Generators.options[:quails][:assets]
      assert_equal false, Quails::Generators.options[:quails][:helper]
      assert_nil Quails::Generators.options[:quails][:template_engine]
    end

    test "api only generators allow overriding generator options" do
      add_to_config <<-RUBY
      config.generators.helper = true
      config.api_only = true
      config.generators.template_engine = :my_template
      RUBY

      # Initialize the application
      require "#{app_path}/config/environment"
      Quails.application.load_generators

      assert Quails::Generators.options[:quails][:api]
      assert Quails::Generators.options[:quails][:helper]
      assert_equal :my_template, Quails::Generators.options[:quails][:template_engine]
    end

    test "api only generator generate mailer views" do
      add_to_config <<-RUBY
        config.api_only = true
      RUBY

      FileUtils.cd(quails_root) { `bin/quails generate mailer notifier foo` }
      assert File.exist?(File.join(quails_root, "app/views/notifier_mailer/foo.text.erb"))
      assert File.exist?(File.join(quails_root, "app/views/notifier_mailer/foo.html.erb"))
    end

    test "ARGV is mutated as expected" do
      require "#{app_path}/config/environment"
      Quails::Command.const_set("APP_PATH", "quails/all")

      FileUtils.cd(quails_root) do
        ARGV = ["mailer", "notifier", "foo"]
        Quails::Command.const_set("ARGV", ARGV)
        quietly { Quails::Command.invoke :generate, ARGV }

        assert_equal ["notifier", "foo"], ARGV
      end

      Quails::Command.send(:remove_const, "APP_PATH")
    end

    test "help does not show hidden namespaces" do
      FileUtils.cd(quails_root) do
        output = `bin/quails generate --help`
        assert_no_match "active_record:migration", output

        output = `bin/quails destroy --help`
        assert_no_match "active_record:migration", output
      end
    end
  end
end

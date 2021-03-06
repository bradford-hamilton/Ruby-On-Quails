# frozen_string_literal: true

require "isolation/abstract_unit"

module ApplicationTests
  class MultipleApplicationsTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::Isolation

    def setup
      build_app(initializers: true)
      require "#{quails_root}/config/environment"
      Quails.application.config.some_setting = "something_or_other"
    end

    def teardown
      teardown_app
    end

    def test_cloning_an_application_makes_a_shallow_copy_of_config
      clone = Quails.application.clone

      assert_equal Quails.application.config, clone.config, "The cloned application should get a copy of the config"
      assert_equal Quails.application.config.some_setting, clone.config.some_setting, "The some_setting on the config should be the same"
    end

    def test_inheriting_multiple_times_from_application
      new_application_class = Class.new(Quails::Application)

      assert_not_equal Quails.application.object_id, new_application_class.instance.object_id
    end

    def test_initialization_of_multiple_copies_of_same_application
      application1 = AppTemplate::Application.new
      application2 = AppTemplate::Application.new

      assert_not_equal Quails.application.object_id, application1.object_id, "New applications should not be the same as the original application"
      assert_not_equal Quails.application.object_id, application2.object_id, "New applications should not be the same as the original application"
    end

    def test_initialization_of_application_with_previous_config
      application1 = AppTemplate::Application.create(config: Quails.application.config)
      application2 = AppTemplate::Application.create

      assert_equal Quails.application.config, application1.config, "Creating a new application while setting an initial config should result in the same config"
      assert_not_equal Quails.application.config, application2.config, "New applications without setting an initial config should not have the same config"
    end

    def test_initialization_of_application_with_previous_railties
      application1 = AppTemplate::Application.create(railties: Quails.application.railties)
      application2 = AppTemplate::Application.create

      assert_equal Quails.application.railties, application1.railties
      assert_not_equal Quails.application.railties, application2.railties
    end

    def test_initialize_new_application_with_all_previous_initialization_variables
      application1 = AppTemplate::Application.create(
        config:           Quails.application.config,
        railties:         Quails.application.railties,
        routes_reloader:  Quails.application.routes_reloader,
        reloaders:        Quails.application.reloaders,
        routes:           Quails.application.routes,
        helpers:          Quails.application.helpers,
        app_env_config:   Quails.application.env_config
      )

      assert_equal Quails.application.config, application1.config
      assert_equal Quails.application.railties, application1.railties
      assert_equal Quails.application.routes_reloader, application1.routes_reloader
      assert_equal Quails.application.reloaders, application1.reloaders
      assert_equal Quails.application.routes, application1.routes
      assert_equal Quails.application.helpers, application1.helpers
      assert_equal Quails.application.env_config, application1.env_config
    end

    def test_rake_tasks_defined_on_different_applications_go_to_the_same_class
      run_count = 0

      application1 = AppTemplate::Application.new
      application1.rake_tasks do
        run_count += 1
      end

      application2 = AppTemplate::Application.new
      application2.rake_tasks do
        run_count += 1
      end

      require "#{app_path}/config/environment"

      assert_equal 0, run_count, "The count should stay at zero without any calls to the rake tasks"
      require "rake"
      require "rake/testtask"
      require "rdoc/task"
      Quails.application.load_tasks
      assert_equal 2, run_count, "Calling a rake task should result in two increments to the count"
    end

    def test_multiple_applications_can_be_initialized
      assert_nothing_raised { AppTemplate::Application.new }
    end

    def test_initializers_run_on_different_applications_go_to_the_same_class
      application1 = AppTemplate::Application.new
      run_count = 0

      AppTemplate::Application.initializer :init0 do
        run_count += 1
      end

      application1.initializer :init1 do
        run_count += 1
      end

      AppTemplate::Application.new.initializer :init2 do
        run_count += 1
      end

      assert_equal 0, run_count, "Without loading the initializers, the count should be 0"

      # Set config.eager_load to false so that an eager_load warning doesn't pop up
      AppTemplate::Application.create { config.eager_load = false }.initialize!

      assert_equal 3, run_count, "There should have been three initializers that incremented the count"
    end

    def test_consoles_run_on_different_applications_go_to_the_same_class
      run_count = 0
      AppTemplate::Application.console { run_count += 1 }
      AppTemplate::Application.new.console { run_count += 1 }

      assert_equal 0, run_count, "Without loading the consoles, the count should be 0"
      Quails.application.load_console
      assert_equal 2, run_count, "There should have been two consoles that increment the count"
    end

    def test_generators_run_on_different_applications_go_to_the_same_class
      run_count = 0
      AppTemplate::Application.generators { run_count += 1 }
      AppTemplate::Application.new.generators { run_count += 1 }

      assert_equal 0, run_count, "Without loading the generators, the count should be 0"
      Quails.application.load_generators
      assert_equal 2, run_count, "There should have been two generators that increment the count"
    end

    def test_runners_run_on_different_applications_go_to_the_same_class
      run_count = 0
      AppTemplate::Application.runner { run_count += 1 }
      AppTemplate::Application.new.runner { run_count += 1 }

      assert_equal 0, run_count, "Without loading the runners, the count should be 0"
      Quails.application.load_runner
      assert_equal 2, run_count, "There should have been two runners that increment the count"
    end

    def test_isolate_namespace_on_an_application
      assert_nil Quails.application.railtie_namespace, "Before isolating namespace, the railtie namespace should be nil"
      Quails.application.isolate_namespace(AppTemplate)
      assert_equal Quails.application.railtie_namespace, AppTemplate, "After isolating namespace, we should have a namespace"
    end

    def test_inserting_configuration_into_application
      app = AppTemplate::Application.new(config: Quails.application.config)
      app.config.some_setting = "a_different_setting"
      assert_equal "a_different_setting", app.config.some_setting, "The configuration's some_setting should be set."

      new_config = Quails::Application::Configuration.new("root_of_application")
      new_config.some_setting = "some_setting_dude"
      app.config = new_config

      assert_equal "some_setting_dude", app.config.some_setting, "The configuration's some_setting should have changed."
      assert_equal "root_of_application", app.config.root, "The root should have changed to the new config's root."
      assert_equal new_config, app.config, "The application's config should have changed to the new config."
    end
  end
end

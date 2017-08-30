# frozen_string_literal: true

module Quails
  module Command
    module Actions
      # Change to the application's path if there is no <tt>config.ru</tt> file in current directory.
      # This allows us to run <tt>quails server</tt> from other directories, but still get
      # the main <tt>config.ru</tt> and properly set the <tt>tmp</tt> directory.
      def set_application_directory!
        Dir.chdir(File.expand_path("../..", APP_PATH)) unless File.exist?(File.expand_path("config.ru"))
      end

      def require_application_and_environment!
        require ENGINE_PATH if defined?(ENGINE_PATH)

        if defined?(APP_PATH)
          require APP_PATH
          Quails.application.require_environment!
        end
      end

      if defined?(ENGINE_PATH)
        def load_tasks
          Rake.application.init("quails")
          Rake.application.load_rakefile
        end

        def load_generators
          engine = ::Quails::Engine.find(ENGINE_ROOT)
          Quails::Generators.namespace = engine.railtie_namespace
          engine.load_generators
        end
      else
        def load_tasks
          Quails.application.load_tasks
        end

        def load_generators
          Quails.application.load_generators
        end
      end
    end
  end
end

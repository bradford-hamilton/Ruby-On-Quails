# frozen_string_literal: true

require_relative "../generators"
require_relative "../generators/quails/plugin/plugin_generator"

module Quails
  class Engine
    class Updater
      class << self
        def generator
          @generator ||= Quails::Generators::PluginGenerator.new ["plugin"],
            { engine: true }, { destination_root: ENGINE_ROOT }
        end

        def run(action)
          generator.send(action)
        end
      end
    end
  end
end

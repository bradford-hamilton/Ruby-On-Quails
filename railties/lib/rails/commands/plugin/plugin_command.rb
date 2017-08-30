# frozen_string_literal: true

module Quails
  module Command
    class PluginCommand < Base # :nodoc:
      hide_command!

      def help
        run_plugin_generator %w( --help )
      end

      def self.banner(*) # :nodoc:
        "#{executable} new [options]"
      end

      class_option :rc, type: :string, default: File.join("~", ".quailsrc"),
        desc: "Initialize the plugin command with previous defaults. Uses .quailsrc in your home directory by default."

      class_option :no_rc, desc: "Skip evaluating .quailsrc."

      def perform(type = nil, *plugin_args)
        plugin_args << "--help" unless type == "new"

        unless options.key?("no_rc") # Thor's not so indifferent access hash.
          quailsrc = File.expand_path(options[:rc])

          if File.exist?(quailsrc)
            extra_args = File.read(quailsrc).split(/\n+/).flat_map(&:split)
            puts "Using #{extra_args.join(" ")} from #{quailsrc}"
            plugin_args.insert(1, *extra_args)
          end
        end

        run_plugin_generator plugin_args
      end

      private
        def run_plugin_generator(plugin_args)
          require_relative "../../generators"
          require_relative "../../generators/quails/plugin/plugin_generator"
          Quails::Generators::PluginGenerator.start plugin_args
        end
    end
  end
end

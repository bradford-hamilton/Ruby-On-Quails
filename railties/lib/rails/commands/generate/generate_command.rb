# frozen_string_literal: true

require_relative "../../generators"

module Quails
  module Command
    class GenerateCommand < Base # :nodoc:
      no_commands do
        def help
          require_application_and_environment!
          load_generators

          Quails::Generators.help self.class.command_name
        end
      end

      def perform(*)
        generator = args.shift
        return help unless generator

        require_application_and_environment!
        load_generators

        ARGV.shift

        Quails::Generators.invoke generator, args, behavior: :invoke, destination_root: Quails::Command.root
      end
    end
  end
end

# frozen_string_literal: true

module Quails
  module Command
    class NewCommand < Base # :nodoc:
      no_commands do
        def help
          Quails::Command.invoke :application, [ "--help" ]
        end
      end

      def perform(*)
        puts "Can't initialize a new Quails application within the directory of another, please change to a non-Quails directory first.\n"
        puts "Type 'quails' for help."
        exit 1
      end
    end
  end
end

# frozen_string_literal: true

module Quails
  module Command
    class HelpCommand < Base # :nodoc:
      hide_command!

      def help(*)
        puts self.class.desc

        Quails::Command.print_commands
      end
    end
  end
end

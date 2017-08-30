# frozen_string_literal: true

module Quails
  module Command
    class VersionCommand < Base # :nodoc:
      def perform
        Quails::Command.invoke :application, [ "--version" ]
      end
    end
  end
end

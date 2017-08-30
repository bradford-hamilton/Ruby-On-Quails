# frozen_string_literal: true

require_relative "app_loader"

# If we are inside a Quails application this method performs an exec and thus
# the rest of this script is not run.
Quails::AppLoader.exec_app

require_relative "ruby_version_check"
Signal.trap("INT") { puts; exit(1) }

require_relative "command"

if ARGV.first == "plugin"
  ARGV.shift
  Quails::Command.invoke :plugin, ARGV
else
  Quails::Command.invoke :application, ARGV
end

# frozen_string_literal: true

require "optparse"

desc "Print out all defined routes in match order, with names. Target specific controller with -c option, or grep routes using -g option"
task routes: :environment do
  all_routes = Quails.application.routes.routes
  require "action_dispatch/routing/inspector"
  inspector = ActionDispatch::Routing::RoutesInspector.new(all_routes)

  routes_filter = nil

  OptionParser.new do |opts|
    opts.banner = "Usage: quails routes [options]"

    Rake.application.standard_rake_options.each { |args| opts.on(*args) }

    opts.on("-c CONTROLLER") do |controller|
      routes_filter = { controller: controller }
    end

    opts.on("-g PATTERN") do |pattern|
      routes_filter = pattern
    end

  end.parse!(ARGV.reject { |x| x == "routes" })

  puts inspector.format(ActionDispatch::Routing::ConsoleFormatter.new, routes_filter)

  exit 0 # ensure extra arguments aren't interpreted as Rake tasks
end

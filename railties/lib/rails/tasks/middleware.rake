# frozen_string_literal: true

desc "Prints out your Rack middleware stack"
task middleware: :environment do
  Quails.configuration.middleware.each do |middleware|
    puts "use #{middleware.inspect}"
  end
  puts "run #{Quails.application.class.name}.routes"
end

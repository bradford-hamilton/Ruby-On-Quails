# frozen_string_literal: true

desc "Print out all defined initializers in the order they are invoked by Quails."
task initializers: :environment do
  Quails.application.initializers.tsort_each do |initializer|
    puts "#{initializer.context_class}.#{initializer.name}"
  end
end

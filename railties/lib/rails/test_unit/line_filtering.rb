# frozen_string_literal: true

require "quails/test_unit/runner"

module Quails
  module LineFiltering # :nodoc:
    def run(reporter, options = {})
      options[:filter] = Quails::TestUnit::Runner.compose_filter(self, options[:filter])

      super
    end
  end
end

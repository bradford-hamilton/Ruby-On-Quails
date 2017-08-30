# frozen_string_literal: true

require "quails/generators"

class UsageTemplateGenerator < Quails::Generators::Base
  source_root File.expand_path("templates", __dir__)
end

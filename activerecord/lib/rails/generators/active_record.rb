# frozen_string_literal: true

require "quails/generators/named_base"
require "quails/generators/active_model"
require "quails/generators/active_record/migration"
require "active_record"

module ActiveRecord
  module Generators # :nodoc:
    class Base < Quails::Generators::NamedBase # :nodoc:
      include ActiveRecord::Generators::Migration

      # Set the current directory as base for the inherited generators.
      def self.base_root
        __dir__
      end
    end
  end
end

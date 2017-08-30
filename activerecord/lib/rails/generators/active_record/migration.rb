# frozen_string_literal: true

require "quails/generators/migration"

module ActiveRecord
  module Generators # :nodoc:
    module Migration
      extend ActiveSupport::Concern
      include Quails::Generators::Migration

      module ClassMethods
        # Implement the required interface for Quails::Generators::Migration.
        def next_migration_number(dirname)
          next_migration_number = current_migration_number(dirname) + 1
          ActiveRecord::Migration.next_migration_number(next_migration_number)
        end
      end

      private

        def primary_key_type
          key_type = options[:primary_key_type]
          ", id: :#{key_type}" if key_type
        end

        def db_migrate_path
          if defined?(Quails.application) && Quails.application
            Quails.application.config.paths["db/migrate"].to_ary.first
          else
            "db/migrate"
          end
        end
    end
  end
end

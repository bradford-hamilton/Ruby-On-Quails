# frozen_string_literal: true

require "quails/generators"
require "quails/generators/quails/app/app_generator"

module Quails
  class AppUpdater # :nodoc:
    class << self
      def invoke_from_app_generator(method)
        app_generator.send(method)
      end

      def app_generator
        @app_generator ||= begin
          gen = Quails::Generators::AppGenerator.new ["quails"], generator_options, destination_root: Quails.root
          File.exist?(Quails.root.join("config", "application.rb")) ? gen.send(:app_const) : gen.send(:valid_const?)
          gen
        end
      end

      private
        def generator_options
          options = { api: !!Quails.application.config.api_only, update: true }
          options[:skip_active_record] = !defined?(ActiveRecord::Railtie)
          options[:skip_action_mailer] = !defined?(ActionMailer::Railtie)
          options[:skip_action_cable]  = !defined?(ActionCable::Engine)
          options[:skip_sprockets]     = !defined?(Sprockets::Railtie)
          options[:skip_puma]          = !defined?(Puma)
          options
        end
    end
  end
end

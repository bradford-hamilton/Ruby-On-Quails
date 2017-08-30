# frozen_string_literal: true

require "active_model"
require "quails"

module ActiveModel
  class Railtie < Quails::Railtie # :nodoc:
    config.eager_load_namespaces << ActiveModel

    initializer "active_model.secure_password" do
      ActiveModel::SecurePassword.min_cost = Quails.env.test?
    end
  end
end

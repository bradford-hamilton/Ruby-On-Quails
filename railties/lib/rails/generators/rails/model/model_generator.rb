# frozen_string_literal: true

require_relative "../../model_helpers"

module Quails
  module Generators
    class ModelGenerator < NamedBase # :nodoc:
      include Quails::Generators::ModelHelpers

      argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"
      hook_for :orm, required: true, desc: "ORM to be invoked"
    end
  end
end

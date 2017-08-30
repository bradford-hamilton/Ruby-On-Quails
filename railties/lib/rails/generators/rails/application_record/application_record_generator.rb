# frozen_string_literal: true

module Quails
  module Generators
    class ApplicationRecordGenerator < Base # :nodoc:
      hook_for :orm, required: true, desc: "ORM to be invoked"
    end
  end
end

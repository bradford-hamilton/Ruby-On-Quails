# frozen_string_literal: true

require_relative "../../named_base"

module Css # :nodoc:
  module Generators # :nodoc:
    class ScaffoldGenerator < Quails::Generators::NamedBase # :nodoc:
      # In order to allow the Sass generators to pick up the default Quails CSS and
      # transform it, we leave it in a standard location for the CSS stylesheet
      # generators to handle. For the simple, default case, just copy it over.
      def copy_stylesheet
        dir = Quails::Generators::ScaffoldGenerator.source_root
        file = File.join(dir, "scaffold.css")
        create_file "app/assets/stylesheets/scaffold.css", File.read(file)
      end
    end
  end
end

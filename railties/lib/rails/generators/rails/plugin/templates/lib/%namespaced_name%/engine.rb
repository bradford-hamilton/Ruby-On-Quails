<%= wrap_in_modules <<-rb.strip_heredoc
  class Engine < ::Quails::Engine
  #{mountable? ? '  isolate_namespace ' + camelized_modules : ' '}
  #{api? ? "  config.generators.api_only = true" : ' '}
  end
rb
%>

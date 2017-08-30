require_relative 'boot'

<% if include_all_railties? -%>
require 'quails/all'
<% else -%>
require "quails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
<%= comment_if :skip_active_record %>require "active_record/railtie"
require "action_controller/railtie"
<%= comment_if :skip_action_mailer %>require "action_mailer/railtie"
require "action_view/railtie"
require "active_storage/engine"
<%= comment_if :skip_action_cable %>require "action_cable/engine"
<%= comment_if :skip_sprockets %>require "sprockets/railtie"
<%= comment_if :skip_test %>require "quails/test_unit/railtie"
<% end -%>

Bundler.require(*Quails.groups)
require "<%= namespaced_name %>"

<%= application_definition %>

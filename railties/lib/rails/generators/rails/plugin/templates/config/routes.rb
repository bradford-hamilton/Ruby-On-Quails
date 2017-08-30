<% if mountable? -%>
<%= camelized_modules %>::Engine.routes.draw do
<% else -%>
Quails.application.routes.draw do
<% end -%>
end

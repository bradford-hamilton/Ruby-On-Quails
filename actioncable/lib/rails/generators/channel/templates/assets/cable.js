// Action Cable provides the framework to deal with WebSockets in Quails.
// You can generate new channels where WebSocket features live using the `quails generate channel` command.
//
//= require action_cable
//= require_self
//= require_tree ./channels

(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();

}).call(this);

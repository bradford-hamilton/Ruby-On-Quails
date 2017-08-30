**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON http://guides.rubyonquails.org.**

The Quails Initialization Process
================================

This guide explains the internals of the initialization process in Quails.
It is an extremely in-depth guide and recommended for advanced Quails developers.

After reading this guide, you will know:

* How to use `quails server`.
* The timeline of Quails' initialization sequence.
* Where different files are required by the boot sequence.
* How the Quails::Server interface is defined and used.

--------------------------------------------------------------------------------

This guide goes through every method call that is
required to boot up the Ruby on Quails stack for a default Quails
application, explaining each part in detail along the way. For this
guide, we will be focusing on what happens when you execute `quails server`
to boot your app.

NOTE: Paths in this guide are relative to Quails or a Quails application unless otherwise specified.

TIP: If you want to follow along while browsing the Quails [source
code](https://github.com/quails/quails), we recommend that you use the `t`
key binding to open the file finder inside GitHub and find files
quickly.

Launch!
-------

Let's start to boot and initialize the app. A Quails application is usually
started by running `quails console` or `quails server`.

### `railties/exe/quails`

The `quails` in the command `quails server` is a ruby executable in your load
path. This executable contains the following lines:

```ruby
version = ">= 0"
load Gem.bin_path('railties', 'quails', version)
```

If you try out this command in a Quails console, you would see that this loads
`railties/exe/quails`. A part of the file `railties/exe/quails.rb` has the
following code:

```ruby
require "quails/cli"
```

The file `railties/lib/quails/cli` in turn calls
`Quails::AppLoader.exec_app`.

### `railties/lib/quails/app_loader.rb`

The primary goal of the function `exec_app` is to execute your app's
`bin/quails`. If the current directory does not have a `bin/quails`, it will
navigate upwards until it finds a `bin/quails` executable. Thus one can invoke a
`quails` command from anywhere inside a quails application.

For `quails server` the equivalent of the following command is executed:

```bash
$ exec ruby bin/quails server
```

### `bin/quails`

This file is as follows:

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require_relative '../config/boot'
require 'quails/commands'
```

The `APP_PATH` constant will be used later in `quails/commands`. The `config/boot` file referenced here is the `config/boot.rb` file in our application which is responsible for loading Bundler and setting it up.

### `config/boot.rb`

`config/boot.rb` contains:

```ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
```

In a standard Quails application, there's a `Gemfile` which declares all
dependencies of the application. `config/boot.rb` sets
`ENV['BUNDLE_GEMFILE']` to the location of this file. If the Gemfile
exists, then `bundler/setup` is required. The require is used by Bundler to
configure the load path for your Gemfile's dependencies.

A standard Quails application depends on several gems, specifically:

* actioncable
* actionmailer
* actionpack
* actionview
* activejob
* activemodel
* activerecord
* activestorage
* activesupport
* arel
* builder
* bundler
* erubi
* i18n
* mail
* mime-types
* rack
* rack-cache
* rack-mount
* rack-test
* quails
* railties
* rake
* sqlite3
* thor
* tzinfo

### `quails/commands.rb`

Once `config/boot.rb` has finished, the next file that is required is
`quails/commands`, which helps in expanding aliases. In the current case, the
`ARGV` array simply contains `server` which will be passed over:

```ruby
require_relative "command"

aliases = {
  "g"  => "generate",
  "d"  => "destroy",
  "c"  => "console",
  "s"  => "server",
  "db" => "dbconsole",
  "r"  => "runner",
  "t"  => "test"
}

command = ARGV.shift
command = aliases[command] || command

Quails::Command.invoke command, ARGV
```

If we had used `s` rather than `server`, Quails would have used the `aliases`
defined here to find the matching command.

### `quails/command.rb`

When one types a Quails command, `invoke` tries to lookup a command for the given
namespace and executes the command if found.

If Quails doesn't recognize the command, it hands the reins over to Rake
to run a task of the same name.

As shown, `Quails::Command` displays the help output automatically if the `args`
are empty.

```ruby
module Quails::Command
  class << self
    def invoke(namespace, args = [], **config)
      namespace = namespace.to_s
      namespace = "help" if namespace.blank? || HELP_MAPPINGS.include?(namespace)
      namespace = "version" if %w( -v --version ).include? namespace

      if command = find_by_namespace(namespace)
        command.perform(namespace, args, config)
      else
        find_by_namespace("rake").perform(namespace, args, config)
      end
    end
  end
end
```

With the `server` command, Quails will further run the following code:

```ruby
module Quails
  module Command
    class ServerCommand < Base # :nodoc:
      def perform
        set_application_directory!

        Quails::Server.new.tap do |server|
          # Require application after server sets environment to propagate
          # the --environment option.
          require APP_PATH
          Dir.chdir(Quails.application.root)
          server.start
        end
      end
    end
  end
end
```

This file will change into the Quails root directory (a path two directories up
from `APP_PATH` which points at `config/application.rb`), but only if the
`config.ru` file isn't found. This then starts up the `Quails::Server` class.

### `actionpack/lib/action_dispatch.rb`

Action Dispatch is the routing component of the Quails framework.
It adds functionality like routing, session, and common middlewares.

### `quails/commands/server/server_command.rb`

The `Quails::Server` class is defined in this file by inheriting from
`Rack::Server`. When `Quails::Server.new` is called, this calls the `initialize`
method in `quails/commands/server/server_command.rb`:

```ruby
def initialize(*)
  super
  set_environment
end
```

Firstly, `super` is called which calls the `initialize` method on `Rack::Server`.

### Rack: `lib/rack/server.rb`

`Rack::Server` is responsible for providing a common server interface for all Rack-based applications, which Quails is now a part of.

The `initialize` method in `Rack::Server` simply sets a couple of variables:

```ruby
def initialize(options = nil)
  @options = options
  @app = options[:app] if options && options[:app]
end
```

In this case, `options` will be `nil` so nothing happens in this method.

After `super` has finished in `Rack::Server`, we jump back to
`quails/commands/server/server_command.rb`. At this point, `set_environment`
is called within the context of the `Quails::Server` object and this method
doesn't appear to do much at first glance:

```ruby
def set_environment
  ENV["RAILS_ENV"] ||= options[:environment]
end
```

In fact, the `options` method here does quite a lot. This method is defined in `Rack::Server` like this:

```ruby
def options
  @options ||= parse_options(ARGV)
end
```

Then `parse_options` is defined like this:

```ruby
def parse_options(args)
  options = default_options

  # Don't evaluate CGI ISINDEX parameters.
  # http://www.meb.uni-bonn.de/docs/cgi/cl.html
  args.clear if ENV.include?("REQUEST_METHOD")

  options.merge! opt_parser.parse!(args)
  options[:config] = ::File.expand_path(options[:config])
  ENV["RACK_ENV"] = options[:environment]
  options
end
```

With the `default_options` set to this:

```ruby
def default_options
  super.merge(
    Port:               ENV.fetch("PORT", 3000).to_i,
    Host:               ENV.fetch("HOST", "localhost").dup,
    DoNotReverseLookup: true,
    environment:        (ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development").dup,
    daemonize:          false,
    caching:            nil,
    pid:                Options::DEFAULT_PID_PATH,
    restart_cmd:        restart_command)
end
```

There is no `REQUEST_METHOD` key in `ENV` so we can skip over that line. The next line merges in the options from `opt_parser` which is defined plainly in `Rack::Server`:

```ruby
def opt_parser
  Options.new
end
```

The class **is** defined in `Rack::Server`, but is overwritten in
`Quails::Server` to take different arguments. Its `parse!` method looks
like this:

```ruby
def parse!(args)
  args, options = args.dup, {}

  option_parser(options).parse! args

  options[:log_stdout] = options[:daemonize].blank? && (options[:environment] || Quails.env) == "development"
  options[:server]     = args.shift
  options
end
```

This method will set up keys for the `options` which Quails will then be
able to use to determine how its server should run. After `initialize`
has finished, we jump back into the server command where `APP_PATH` (which was
set earlier) is required.

### `config/application`

When `require APP_PATH` is executed, `config/application.rb` is loaded (recall
that `APP_PATH` is defined in `bin/quails`). This file exists in your application
and it's free for you to change based on your needs.

### `Quails::Server#start`

After `config/application` is loaded, `server.start` is called. This method is
defined like this:

```ruby
def start
  print_boot_information
  trap(:INT) { exit }
  create_tmp_directories
  setup_dev_caching
  log_to_stdout if options[:log_stdout]

  super
  ...
end

private
  def print_boot_information
    ...
    puts "=> Run `quails server -h` for more startup options"
  end

  def create_tmp_directories
    %w(cache pids sockets).each do |dir_to_make|
      FileUtils.mkdir_p(File.join(Quails.root, 'tmp', dir_to_make))
    end
  end

  def setup_dev_caching
    if options[:environment] == "development"
      Quails::DevCaching.enable_by_argument(options[:caching])
    end
  end

  def log_to_stdout
    wrapped_app # touch the app so the logger is set up

    console = ActiveSupport::Logger.new(STDOUT)
    console.formatter = Quails.logger.formatter
    console.level = Quails.logger.level

    unless ActiveSupport::Logger.logger_outputs_to?(Quails.logger, STDOUT)
      Quails.logger.extend(ActiveSupport::Logger.broadcast(console))
    end
  end
```

This is where the first output of the Quails initialization happens. This method
creates a trap for `INT` signals, so if you `CTRL-C` the server, it will exit the
process. As we can see from the code here, it will create the `tmp/cache`,
`tmp/pids`, and `tmp/sockets` directories. It then enables caching in development
if `quails server` is called with `--dev-caching`. Finally, it calls `wrapped_app` which is
responsible for creating the Rack app, before creating and assigning an instance
of `ActiveSupport::Logger`.

The `super` method will call `Rack::Server.start` which begins its definition like this:

```ruby
def start &blk
  if options[:warn]
    $-w = true
  end

  if includes = options[:include]
    $LOAD_PATH.unshift(*includes)
  end

  if library = options[:require]
    require library
  end

  if options[:debug]
    $DEBUG = true
    require 'pp'
    p options[:server]
    pp wrapped_app
    pp app
  end

  check_pid! if options[:pid]

  # Touch the wrapped app, so that the config.ru is loaded before
  # daemonization (i.e. before chdir, etc).
  wrapped_app

  daemonize_app if options[:daemonize]

  write_pid if options[:pid]

  trap(:INT) do
    if server.respond_to?(:shutdown)
      server.shutdown
    else
      exit
    end
  end

  server.run wrapped_app, options, &blk
end
```

The interesting part for a Quails app is the last line, `server.run`. Here we encounter the `wrapped_app` method again, which this time
we're going to explore more (even though it was executed before, and
thus memoized by now).

```ruby
@wrapped_app ||= build_app app
```

The `app` method here is defined like so:

```ruby
def app
  @app ||= options[:builder] ? build_app_from_string : build_app_and_options_from_config
end
...
private
  def build_app_and_options_from_config
    if !::File.exist? options[:config]
      abort "configuration #{options[:config]} not found"
    end

    app, options = Rack::Builder.parse_file(self.options[:config], opt_parser)
    self.options.merge! options
    app
  end

  def build_app_from_string
    Rack::Builder.new_from_string(self.options[:builder])
  end
```

The `options[:config]` value defaults to `config.ru` which contains this:

```ruby
# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
run <%= app_const %>
```


The `Rack::Builder.parse_file` method here takes the content from this `config.ru` file and parses it using this code:

```ruby
app = new_from_string cfgfile, config

...

def self.new_from_string(builder_script, file="(rackup)")
  eval "Rack::Builder.new {\n" + builder_script + "\n}.to_app",
    TOPLEVEL_BINDING, file, 0
end
```

The `initialize` method of `Rack::Builder` will take the block here and execute it within an instance of `Rack::Builder`. This is where the majority of the initialization process of Quails happens. The `require` line for `config/environment.rb` in `config.ru` is the first to run:

```ruby
require_relative 'config/environment'
```

### `config/environment.rb`

This file is the common file required by `config.ru` (`quails server`) and Passenger. This is where these two ways to run the server meet; everything before this point has been Rack and Quails setup.

This file begins with requiring `config/application.rb`:

```ruby
require_relative 'application'
```

### `config/application.rb`

This file requires `config/boot.rb`:

```ruby
require_relative 'boot'
```

But only if it hasn't been required before, which would be the case in `quails server`
but **wouldn't** be the case with Passenger.

Then the fun begins!

Loading Quails
-------------

The next line in `config/application.rb` is:

```ruby
require 'quails/all'
```

### `railties/lib/quails/all.rb`

This file is responsible for requiring all the individual frameworks of Quails:

```ruby
require "quails"

%w(
  active_record/railtie
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  action_cable/engine
  active_storage/engine
  quails/test_unit/railtie
  sprockets/railtie
).each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end
```

This is where all the Quails frameworks are loaded and thus made
available to the application. We won't go into detail of what happens
inside each of those frameworks, but you're encouraged to try and
explore them on your own.

For now, just keep in mind that common functionality like Quails engines,
I18n and Quails configuration are all being defined here.

### Back to `config/environment.rb`

The rest of `config/application.rb` defines the configuration for the
`Quails::Application` which will be used once the application is fully
initialized. When `config/application.rb` has finished loading Quails and defined
the application namespace, we go back to `config/environment.rb`. Here, the
application is initialized with `Quails.application.initialize!`, which is
defined in `quails/application.rb`.

### `railties/lib/quails/application.rb`

The `initialize!` method looks like this:

```ruby
def initialize!(group=:default) #:nodoc:
  raise "Application has been already initialized." if @initialized
  run_initializers(group, self)
  @initialized = true
  self
end
```

As you can see, you can only initialize an app once. The initializers are run through
the `run_initializers` method which is defined in `railties/lib/quails/initializable.rb`:

```ruby
def run_initializers(group=:default, *args)
  return if instance_variable_defined?(:@ran)
  initializers.tsort_each do |initializer|
    initializer.run(*args) if initializer.belongs_to?(group)
  end
  @ran = true
end
```

The `run_initializers` code itself is tricky. What Quails is doing here is
traversing all the class ancestors looking for those that respond to an
`initializers` method. It then sorts the ancestors by name, and runs them.
For example, the `Engine` class will make all the engines available by
providing an `initializers` method on them.

The `Quails::Application` class, as defined in `railties/lib/quails/application.rb`
defines `bootstrap`, `railtie`, and `finisher` initializers. The `bootstrap` initializers
prepare the application (like initializing the logger) while the `finisher`
initializers (like building the middleware stack) are run last. The `railtie`
initializers are the initializers which have been defined on the `Quails::Application`
itself and are run between the `bootstrap` and `finishers`.

After this is done we go back to `Rack::Server`.

### Rack: lib/rack/server.rb

Last time we left when the `app` method was being defined:

```ruby
def app
  @app ||= options[:builder] ? build_app_from_string : build_app_and_options_from_config
end
...
private
  def build_app_and_options_from_config
    if !::File.exist? options[:config]
      abort "configuration #{options[:config]} not found"
    end

    app, options = Rack::Builder.parse_file(self.options[:config], opt_parser)
    self.options.merge! options
    app
  end

  def build_app_from_string
    Rack::Builder.new_from_string(self.options[:builder])
  end
```

At this point `app` is the Quails app itself (a middleware), and what
happens next is Rack will call all the provided middlewares:

```ruby
def build_app(app)
  middleware[options[:environment]].reverse_each do |middleware|
    middleware = middleware.call(self) if middleware.respond_to?(:call)
    next unless middleware
    klass = middleware.shift
    app = klass.new(app, *middleware)
  end
  app
end
```

Remember, `build_app` was called (by `wrapped_app`) in the last line of `Server#start`.
Here's how it looked like when we left:

```ruby
server.run wrapped_app, options, &blk
```

At this point, the implementation of `server.run` will depend on the
server you're using. For example, if you were using Puma, here's what
the `run` method would look like:

```ruby
...
DEFAULT_OPTIONS = {
  :Host => '0.0.0.0',
  :Port => 8080,
  :Threads => '0:16',
  :Verbose => false
}

def self.run(app, options = {})
  options = DEFAULT_OPTIONS.merge(options)

  if options[:Verbose]
    app = Rack::CommonLogger.new(app, STDOUT)
  end

  if options[:environment]
    ENV['RACK_ENV'] = options[:environment].to_s
  end

  server   = ::Puma::Server.new(app)
  min, max = options[:Threads].split(':', 2)

  puts "Puma #{::Puma::Const::PUMA_VERSION} starting..."
  puts "* Min threads: #{min}, max threads: #{max}"
  puts "* Environment: #{ENV['RACK_ENV']}"
  puts "* Listening on tcp://#{options[:Host]}:#{options[:Port]}"

  server.add_tcp_listener options[:Host], options[:Port]
  server.min_threads = min
  server.max_threads = max
  yield server if block_given?

  begin
    server.run.join
  rescue Interrupt
    puts "* Gracefully stopping, waiting for requests to finish"
    server.stop(true)
    puts "* Goodbye!"
  end

end
```

We won't dig into the server configuration itself, but this is
the last piece of our journey in the Quails initialization process.

This high level overview will help you understand when your code is
executed and how, and overall become a better Quails developer. If you
still want to know more, the Quails source code itself is probably the
best place to go next.

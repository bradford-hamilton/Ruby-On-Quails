**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON http://guides.rubyonquails.org.**

The Quails Command Line
======================

After reading this guide, you will know:

* How to create a Quails application.
* How to generate models, controllers, database migrations, and unit tests.
* How to start a development server.
* How to experiment with objects through an interactive shell.

--------------------------------------------------------------------------------

NOTE: This tutorial assumes you have basic Quails knowledge from reading the [Getting Started with Quails Guide](getting_started.html).

Command Line Basics
-------------------

There are a few commands that are absolutely critical to your everyday usage of Quails. In the order of how much you'll probably use them are:

* `quails console`
* `quails server`
* `bin/quails`
* `quails generate`
* `quails dbconsole`
* `quails new app_name`

All commands can run with `-h` or `--help` to list more information.

Let's create a simple Quails application to step through each of these commands in context.

### `quails new`

The first thing we'll want to do is create a new Quails application by running the `quails new` command after installing Quails.

INFO: You can install the quails gem by typing `gem install quails`, if you don't have it already.

```bash
$ quails new commandsapp
     create
     create  README.md
     create  Rakefile
     create  config.ru
     create  .gitignore
     create  Gemfile
     create  app
     ...
     create  tmp/cache
     ...
        run  bundle install
```

Quails will set you up with what seems like a huge amount of stuff for such a tiny command! You've got the entire Quails directory structure now with all the code you need to run our simple application right out of the box.

### `quails server`

The `quails server` command launches a web server named Puma which comes bundled with Quails. You'll use this any time you want to access your application through a web browser.

With no further work, `quails server` will run our new shiny Quails app:

```bash
$ cd commandsapp
$ bin/quails server
=> Booting Puma
=> Quails 5.1.0 application starting in development on http://0.0.0.0:3000
=> Run `quails server -h` for more startup options
Puma starting in single mode...
* Version 3.0.2 (ruby 2.3.0-p0), codename: Plethora of Penguin Pinatas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://localhost:3000
Use Ctrl-C to stop
```

With just three commands we whipped up a Quails server listening on port 3000. Go to your browser and open [http://localhost:3000](http://localhost:3000), you will see a basic Quails app running.

INFO: You can also use the alias "s" to start the server: `quails s`.

The server can be run on a different port using the `-p` option. The default development environment can be changed using `-e`.

```bash
$ bin/quails server -e production -p 4000
```

The `-b` option binds Quails to the specified IP, by default it is localhost. You can run a server as a daemon by passing a `-d` option.

### `quails generate`

The `quails generate` command uses templates to create a whole lot of things. Running `quails generate` by itself gives a list of available generators:

INFO: You can also use the alias "g" to invoke the generator command: `quails g`.

```bash
$ bin/quails generate
Usage: quails generate GENERATOR [args] [options]

...
...

Please choose a generator below.

Quails:
  assets
  channel
  controller
  generator
  ...
  ...
```

NOTE: You can install more generators through generator gems, portions of plugins you'll undoubtedly install, and you can even create your own!

Using generators will save you a large amount of time by writing **boilerplate code**, code that is necessary for the app to work.

Let's make our own controller with the controller generator. But what command should we use? Let's ask the generator:

INFO: All Quails console utilities have help text. As with most *nix utilities, you can try adding `--help` or `-h` to the end, for example `quails server --help`.

```bash
$ bin/quails generate controller
Usage: quails generate controller NAME [action action] [options]

...
...

Description:
    ...

    To create a controller within a module, specify the controller name as a path like 'parent_module/controller_name'.

    ...

Example:
    `quails generate controller CreditCards open debit credit close`

    Credit card controller with URLs like /credit_cards/debit.
        Controller: app/controllers/credit_cards_controller.rb
        Test:       test/controllers/credit_cards_controller_test.rb
        Views:      app/views/credit_cards/debit.html.erb [...]
        Helper:     app/helpers/credit_cards_helper.rb
```

The controller generator is expecting parameters in the form of `generate controller ControllerName action1 action2`. Let's make a `Greetings` controller with an action of **hello**, which will say something nice to us.

```bash
$ bin/quails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
      route  get "greetings/hello"
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke  assets
     invoke    coffee
     create      app/assets/javascripts/greetings.coffee
     invoke    scss
     create      app/assets/stylesheets/greetings.scss
```

What all did this generate? It made sure a bunch of directories were in our application, and created a controller file, a view file, a functional test file, a helper for the view, a JavaScript file and a stylesheet file.

Check out the controller and modify it a little (in `app/controllers/greetings_controller.rb`):

```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Hello, how are you today?"
  end
end
```

Then the view, to display our message (in `app/views/greetings/hello.html.erb`):

```erb
<h1>A Greeting for You!</h1>
<p><%= @message %></p>
```

Fire up your server using `quails server`.

```bash
$ bin/quails server
=> Booting Puma...
```

The URL will be [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello).

INFO: With a normal, plain-old Quails application, your URLs will generally follow the pattern of http://(host)/(controller)/(action), and a URL like http://(host)/(controller) will hit the **index** action of that controller.

Quails comes with a generator for data models too.

```bash
$ bin/quails generate model
Usage:
  quails generate model NAME [field[:type][:index] field[:type][:index]] [options]

...

Active Record options:
      [--migration]            # Indicates when to generate migration
                               # Default: true

...

Description:
    Create quails files for model generator.
```

NOTE: For a list of available field types for the `type` parameter, refer to the [API documentation](http://api.rubyonquails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column) for the add_column method for the `SchemaStatements` module. The `index` parameter generates a corresponding index for the column.

But instead of generating a model directly (which we'll be doing later), let's set up a scaffold. A **scaffold** in Quails is a full set of model, database migration for that model, controller to manipulate it, views to view and manipulate the data, and a test suite for each of the above.

We will set up a simple resource called "HighScore" that will keep track of our highest score on video games we play.

```bash
$ bin/quails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20130717151933_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    invoke    erb
    create      app/views/high_scores
    create      app/views/high_scores/index.html.erb
    create      app/views/high_scores/edit.html.erb
    create      app/views/high_scores/show.html.erb
    create      app/views/high_scores/new.html.erb
    create      app/views/high_scores/_form.html.erb
    invoke    test_unit
    create      test/controllers/high_scores_controller_test.rb
    invoke    helper
    create      app/helpers/high_scores_helper.rb
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    invoke  test_unit
    create    test/system/high_scores_test.rb
    invoke  assets
    invoke    coffee
    create      app/assets/javascripts/high_scores.coffee
    invoke    scss
    create      app/assets/stylesheets/high_scores.scss
    invoke  scss
   identical    app/assets/stylesheets/scaffolds.scss
```

The generator checks that there exist the directories for models, controllers, helpers, layouts, functional and unit tests, stylesheets, creates the views, controller, model and database migration for HighScore (creating the `high_scores` table and fields), takes care of the route for the **resource**, and new tests for everything.

The migration requires that we **migrate**, that is, run some Ruby code (living in that `20130717151933_create_high_scores.rb`) to modify the schema of our database. Which database? The SQLite3 database that Quails will create for you when we run the `bin/quails db:migrate` command. We'll talk more about bin/quails in-depth in a little while.

```bash
$ bin/quails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFO: Let's talk about unit tests. Unit tests are code that tests and makes assertions
about code. In unit testing, we take a little part of code, say a method of a model,
and test its inputs and outputs. Unit tests are your friend. The sooner you make
peace with the fact that your quality of life will drastically increase when you unit
test your code, the better. Seriously. Please visit
[the testing guide](http://guides.rubyonquails.org/testing.html) for an in-depth
look at unit testing.

Let's see the interface Quails created for us.

```bash
$ bin/quails server
```

Go to your browser and open [http://localhost:3000/high_scores](http://localhost:3000/high_scores), now we can create new high scores (55,160 on Space Invaders!)

### `quails console`

The `console` command lets you interact with your Quails application from the command line. On the underside, `quails console` uses IRB, so if you've ever used it, you'll be right at home. This is useful for testing out quick ideas with code and changing data server-side without touching the website.

INFO: You can also use the alias "c" to invoke the console: `quails c`.

You can specify the environment in which the `console` command should operate.

```bash
$ bin/quails console staging
```

If you wish to test out some code without changing any data, you can do that by invoking `quails console --sandbox`.

```bash
$ bin/quails console --sandbox
Loading development environment in sandbox (Quails 5.1.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### The app and helper objects

Inside the `quails console` you have access to the `app` and `helper` instances.

With the `app` method you can access url and path helpers, as well as do requests.

```bash
>> app.root_path
=> "/"

>> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

With the `helper` method it is possible to access Quails and your application's helpers.

```bash
>> helper.time_ago_in_words 30.days.ago
=> "about 1 month"

>> helper.my_custom_helper
=> "my custom helper"
```

### `quails dbconsole`

`quails dbconsole` figures out which database you're using and drops you into whichever command line interface you would use with it (and figures out the command line parameters to give to it, too!). It supports MySQL (including MariaDB), PostgreSQL and SQLite3.

INFO: You can also use the alias "db" to invoke the dbconsole: `quails db`.

### `quails runner`

`runner` runs Ruby code in the context of Quails non-interactively. For instance:

```bash
$ bin/quails runner "Model.long_running_method"
```

INFO: You can also use the alias "r" to invoke the runner: `quails r`.

You can specify the environment in which the `runner` command should operate using the `-e` switch.

```bash
$ bin/quails runner -e staging "Model.long_running_method"
```

You can even execute ruby code written in a file with runner.

```bash
$ bin/quails runner lib/code_to_be_run.rb
```

### `quails destroy`

Think of `destroy` as the opposite of `generate`. It'll figure out what generate did, and undo it.

INFO: You can also use the alias "d" to invoke the destroy command: `quails d`.

```bash
$ bin/quails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```
```bash
$ bin/quails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

bin/quails
---------

Since Quails 5.0+ has rake commands built into the quails executable, `bin/quails` is the new default for running commands.

You can get a list of bin/quails tasks available to you, which will often depend on your current directory, by typing `bin/quails --help`. Each task has a description, and should help you find the thing you need.

```bash
$ bin/quails --help
Usage: quails COMMAND [ARGS]

The most common quails commands are:
generate    Generate new code (short-cut alias: "g")
console     Start the Quails console (short-cut alias: "c")
server      Start the Quails server (short-cut alias: "s")
...

All commands can be run with -h (or --help) for more information.

In addition to those commands, there are:
about                               List versions of all Quails ...
assets:clean[keep]                  Remove old compiled assets
assets:clobber                      Remove compiled assets
assets:environment                  Load asset compile environment
assets:precompile                   Compile all the assets ...
...
db:fixtures:load                    Loads fixtures into the ...
db:migrate                          Migrate the database ...
db:migrate:status                   Display status of migrations
db:rollback                         Rolls the schema back to ...
db:schema:cache:clear               Clears a db/schema_cache.yml file
db:schema:cache:dump                Creates a db/schema_cache.yml file
db:schema:dump                      Creates a db/schema.rb file ...
db:schema:load                      Loads a schema.rb file ...
db:seed                             Loads the seed data ...
db:structure:dump                   Dumps the database structure ...
db:structure:load                   Recreates the databases ...
db:version                          Retrieves the current schema ...
...
restart                             Restart app by touching ...
tmp:create                          Creates tmp directories ...
```
INFO: You can also use `bin/quails -T`  to get the list of tasks.

### `about`

`bin/quails about` gives information about version numbers for Ruby, RubyGems, Quails, the Quails subcomponents, your application's folder, the current Quails environment name, your app's database adapter, and schema version. It is useful when you need to ask for help, check if a security patch might affect you, or when you need some stats for an existing Quails installation.

```bash
$ bin/quails about
About your application's environment
Quails version             5.1.0
Ruby version              2.2.2 (x86_64-linux)
RubyGems version          2.4.6
Rack version              2.0.1
JavaScript Runtime        Node.js (V8)
Middleware:               Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Quails::QuietAssets, Quails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
Application root          /home/foobar/commandsapp
Environment               development
Database adapter          sqlite3
Database schema version   20110805173523
```

### `assets`

You can precompile the assets in `app/assets` using `bin/quails assets:precompile`, and remove older compiled assets using `bin/quails assets:clean`. The `assets:clean` task allows for rolling deploys that may still be linking to an old asset while the new assets are being built.

If you want to clear `public/assets` completely, you can use `bin/quails assets:clobber`.

### `db`

The most common tasks of the `db:` bin/quails namespace are `migrate` and `create`, and it will pay off to try out all of the migration bin/quails tasks (`up`, `down`, `redo`, `reset`). `bin/quails db:version` is useful when troubleshooting, telling you the current version of the database.

More information about migrations can be found in the [Migrations](active_record_migrations.html) guide.

### `notes`

`bin/quails notes` will search through your code for comments beginning with FIXME, OPTIMIZE or TODO. The search is done in files with extension `.builder`, `.rb`, `.rake`, `.yml`, `.yaml`, `.ruby`, `.css`, `.js` and `.erb` for both default and custom annotations.

```bash
$ bin/quails notes
(in /home/foobar/commandsapp)
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/models/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

You can add support for new file extensions using `config.annotations.register_extensions` option, which receives a list of the extensions with its corresponding regex to match it up.

```ruby
config.annotations.register_extensions("scss", "sass", "less") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

If you are looking for a specific annotation, say FIXME, you can use `bin/quails notes:fixme`. Note that you have to lower case the annotation's name.

```bash
$ bin/quails notes:fixme
(in /home/foobar/commandsapp)
app/controllers/admin/users_controller.rb:
  * [132] high priority for next deploy

app/models/school.rb:
  * [ 17]
```

You can also use custom annotations in your code and list them using `bin/quails notes:custom` by specifying the annotation using an environment variable `ANNOTATION`.

```bash
$ bin/quails notes:custom ANNOTATION=BUG
(in /home/foobar/commandsapp)
app/models/article.rb:
  * [ 23] Have to fix this one before pushing!
```

NOTE. When using specific annotations and custom annotations, the annotation name (FIXME, BUG etc) is not displayed in the output lines.

By default, `quails notes` will look in the `app`, `config`, `db`, `lib` and `test` directories. If you would like to search other directories, you can configure them using `config.annotations.register_directories` option.

```ruby
config.annotations.register_directories("spec", "vendor")
```

You can also provide them as a comma separated list in the environment variable `SOURCE_ANNOTATION_DIRECTORIES`.

```bash
$ export SOURCE_ANNOTATION_DIRECTORIES='spec,vendor'
$ bin/quails notes
(in /home/foobar/commandsapp)
app/models/user.rb:
  * [ 35] [FIXME] User should have a subscription at this point
spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works
```

### `routes`

`quails routes` will list all of your defined routes, which is useful for tracking down routing problems in your app, or giving you a good overview of the URLs in an app you're trying to get familiar with.

### `test`

INFO: A good description of unit testing in Quails is given in [A Guide to Testing Quails Applications](testing.html)

Quails comes with a test suite called Minitest. Quails owes its stability to the use of tests. The tasks available in the `test:` namespace helps in running the different tests you will hopefully write.

### `tmp`

The `Quails.root/tmp` directory is, like the *nix /tmp directory, the holding place for temporary files like process id files and cached actions.

The `tmp:` namespaced tasks will help you clear and create the `Quails.root/tmp` directory:

* `quails tmp:cache:clear` clears `tmp/cache`.
* `quails tmp:sockets:clear` clears `tmp/sockets`.
* `quails tmp:screenshots:clear` clears `tmp/screenshots`.
* `quails tmp:clear` clears all cache, sockets and screenshot files.
* `quails tmp:create` creates tmp directories for cache, sockets and pids.

### Miscellaneous

* `quails stats` is great for looking at statistics on your code, displaying things like KLOCs (thousands of lines of code) and your code to test ratio.
* `quails secret` will give you a pseudo-random key to use for your session secret.
* `quails time:zones:all` lists all the timezones Quails knows about.

### Custom Rake Tasks

Custom rake tasks have a `.rake` extension and are placed in
`Quails.root/lib/tasks`. You can create these custom rake tasks with the
`bin/quails generate task` command.

```ruby
desc "I am short, but comprehensive description for my cool task"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # All your magic here
  # Any valid Ruby code is allowed
end
```

To pass arguments to your custom rake task:

```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

You can group tasks by placing them in namespaces:

```ruby
namespace :db do
  desc "This task does nothing"
  task :nothing do
    # Seriously, nothing
  end
end
```

Invocation of the tasks will look like:

```bash
$ bin/quails task_name
$ bin/quails "task_name[value 1]" # entire argument string should be quoted
$ bin/quails db:nothing
```

NOTE: If your need to interact with your application models, perform database queries and so on, your task should depend on the `environment` task, which will load your application code.

The Quails Advanced Command Line
-------------------------------

More advanced use of the command line is focused around finding useful (even surprising at times) options in the utilities, and fitting those to your needs and specific work flow. Listed here are some tricks up Quails' sleeve.

### Quails with Databases and SCM

When creating a new Quails application, you have the option to specify what kind of database and what kind of source code management system your application is going to use. This will save you a few minutes, and certainly many keystrokes.

Let's see what a `--git` option and a `--database=postgresql` option will do for us:

```bash
$ mkdir gitapp
$ cd gitapp
$ git init
Initialized empty Git repository in .git/
$ quails new . --git --database=postgresql
      exists
      create  app/controllers
      create  app/helpers
...
...
      create  tmp/cache
      create  tmp/pids
      create  Rakefile
add 'Rakefile'
      create  README.md
add 'README.md'
      create  app/controllers/application_controller.rb
add 'app/controllers/application_controller.rb'
      create  app/helpers/application_helper.rb
...
      create  log/test.log
add 'log/test.log'
```

We had to create the **gitapp** directory and initialize an empty git repository before Quails would add files it created to our repository. Let's see what it put in our database configuration:

```bash
$ cat config/database.yml
# PostgreSQL. Versions 9.1 and up are supported.
#
# Install the pg driver:
#   gem install pg
# On OS X with Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# On OS X with MacPorts:
#   gem install pg -- --with-pg-config=/opt/local/lib/postgresql84/bin/pg_config
# On Windows:
#   gem install pg
#       Choose the win32 build.
#       Install PostgreSQL and put its /bin directory on your path.
#
# Configure Using Gemfile
# gem 'pg'
#
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Quails configuration guide
  # http://guides.rubyonquails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: gitapp_development
...
...
```

It also generated some lines in our database.yml configuration corresponding to our choice of PostgreSQL for database.

NOTE. The only catch with using the SCM options is that you have to make your application's directory first, then initialize your SCM, then you can run the `quails new` command to generate the basis of your app.

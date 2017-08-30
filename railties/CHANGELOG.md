*   Add `--skip-yarn` option to the plugin generator.

    *bogdanvlviv*

*   Optimize routes indentation.

    *Yoshiyuki Hirano*

*   Optimize indentation for generator actions.

    *Yoshiyuki Hirano*

*   Skip unused components when running `bin/quails` in Quails plugin.

    *Yoshiyuki Hirano*

*   Add `git_source` to `Gemfile` for plugin generator.

    *Yoshiyuki Hirano*

*   Add `--skip-action-cable` option to the plugin generator.

    *bogdanvlviv*

*   Deprecate support of use `Quails::Application` subclass to start Quails server.

    *Yuji Yaginuma*

*   Add `ruby x.x.x` version to `Gemfile` and create `.ruby-version`
    root file containing the current Ruby version when new Quails applications are
    created.

    *Alberto Almagro*

*   Support `-` as a platform-agnostic way to run a script from stdin with
    `quails runner`

    *Cody Cutrer*

*   Add `bootsnap` to default `Gemfile`.

    *Burke Libbey*

*   Properly expand shortcuts for environment's name running the `console`
    and `dbconsole` commands.

    *Robin Dupret*

*   Passing the environment's name as a regular argument to the
    `quails dbconsole` and `quails console` commands is deprecated.
    The `-e` option should be used instead.

    Previously:

        $ bin/quails dbconsole production

    Now:

        $ bin/quails dbconsole -e production

    *Robin Dupret*, *Kasper Timm Hansen*

*   Allow passing a custom connection name to the `quails dbconsole`
    command when using a 3-level database configuration.

        $ bin/quails dbconsole -c replica

    *Robin Dupret*, *Jeremy Daer*

*   Skip unused components when running `bin/quails app:update`.

    If the initial app generation skipped Action Cable, Active Record etc.,
    the update task honors those skips too.

    *Yuji Yaginuma*

*   Make Quails' test runner work better with minitest plugins.

    By demoting the Quails test runner to just another minitest plugin —
    and thereby not eager loading it — we can co-exist much better with
    other minitest plugins such as pride and minitest-focus.

    *Kasper Timm Hansen*

*   Load environment file in `dbconsole` command.

    Fixes #29717.

    *Yuji Yaginuma*

*   Add `quails secrets:show` command.

    *Yuji Yaginuma*

*   Allow mounting the same engine several times in different locations.

    Fixes #20204.

    *David Rodríguez*

*   Clear screenshot files in `tmp:clear` task.

    *Yuji Yaginuma*

*   Add `railtie.rb` to the plugin generator

    *Tsukuru Tanimichi*

*   Deprecate `capify!` method in generators and templates.

    *Yuji Yaginuma*

*   Allow irb options to be passed from `quails console` command.

    Fixes #28988.

    *Yuji Yaginuma*

*   Added a shared section to `config/database.yml` that will be loaded for all environments.

    *Pierre Schambacher*

*   Namespace error pages' CSS selectors to stop the styles from bleeding into other pages
    when using Turbolinks.

    *Jan Krutisch*


Please check [5-1-stable](https://github.com/quails/quails/blob/5-1-stable/railties/CHANGELOG.md) for previous changes.

*   Make `take_failed_screenshot` work within engine.

    Fixes #30405.

    *Yuji Yaginuma*

*   Deprecate `ActionDispatch::TestResponse` response aliases

    `#success?`, `#missing?` & `#error?` are not supported by the actual
    `ActionDispatch::Response` object and can produce false-positives. Instead,
    use the response helpers provided by `Rack::Response`.

    *Trevor Wistaff*

*   Protect from forgery by default

    Rather than protecting from forgery in the generated `ApplicationController`,
    add it to `ActionController::Base` depending on
    `config.action_controller.default_protect_from_forgery`. This configuration
    defaults to false to support older versions which have removed it from their
    `ApplicationController`, but is set to true for Quails 5.2.

    *Lisa Ugray*

*   Fallback `ActionController::Parameters#to_s` to `Hash#to_s`.

    *Kir Shatrov*

*   `driven_by` now registers poltergeist and capybara-webkit

    If poltergeist or capybara-webkit are set as drivers is set for System Tests,
    `driven_by` will register the driver and set additional options passed via
    the `:options` parameter.

    Refer to the respective driver's documentation to see what options can be passed.

    *Mario Chavez*

*   AEAD encrypted cookies and sessions with GCM

    Encrypted cookies now use AES-GCM which couples authentication and
    encryption in one faster step and produces shorter ciphertexts. Cookies
    encrypted using AES in CBC HMAC mode will be seamlessly upgraded when
    this new mode is enabled via the
    `action_dispatch.use_authenticated_cookie_encryption` configuration value.

    *Michael J Coyne*

*   Change the cache key format for fragments to make it easier to debug key churn. The new format is:

        views/template/action.html.erb:7a1156131a6928cb0026877f8b749ac9/projects/123
              ^template path           ^template tree digest            ^class   ^id

    *DHH*

*   Add support for recyclable cache keys with fragment caching. This uses the new versioned entries in the
    `ActiveSupport::Cache` stores and relies on the fact that Active Record has split `#cache_key` and `#cache_version`
    to support it.

    *DHH*

*   Add `action_controller_api` and `action_controller_base` load hooks to be called in `ActiveSupport.on_load`

    `ActionController::Base` and `ActionController::API` have differing implementations. This means that
    the one umbrella hook `action_controller` is not able to address certain situations where a method
    may not exist in a certain implementation.

    This is fixed by adding two new hooks so you can target `ActionController::Base` vs `ActionController::API`

    Fixes #27013.

    *Julian Nadeau*


Please check [5-1-stable](https://github.com/quails/quails/blob/5-1-stable/actionpack/CHANGELOG.md) for previous changes.

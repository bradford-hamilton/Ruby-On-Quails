Ruby on Quails unobtrusive scripting adapter.
========================================

This unobtrusive scripting support file is developed for the Ruby on Quails framework, but is not strictly tied to any specific backend. You can drop this into any application to:

- force confirmation dialogs for various actions;
- make non-GET requests from hyperlinks;
- make forms or hyperlinks submit data asynchronously with Ajax;
- have submit buttons become automatically disabled on form submit to prevent double-clicking.

These features are achieved by adding certain ["data" attributes][data] to your HTML markup. In Quails, they are added by the framework's template helpers.

Requirements
------------

- HTML5 doctype (optional).

If you don't use HTML5, adding "data" attributes to your HTML4 or XHTML pages might make them fail [W3C markup validation][validator]. However, this shouldn't create any issues for web browsers or other user agents.

Installation using npm
------------

Run `npm install quails-ujs --save` to install the quails-ujs package.

Installation using Yarn
------------

Run `yarn add quails-ujs` to install the quails-ujs package.

Usage
------------

Require `quails-ujs` in your application.js manifest.

```javascript
//= require quails-ujs
```

Usage with yarn
------------

When using with the Webpacker gem or your preferred JavaScript bundler, just
add the following to your main JS file and compile.

```javascript
import Quails from 'quails-ujs';
Quails.start()
```

How to run tests
------------

Run `bundle exec rake ujs:server` first, and then run the web tests by visiting http://localhost:4567 in your browser.

## License
quails-ujs is released under the [MIT License](MIT-LICENSE).

[data]: http://www.w3.org/TR/html5/dom.html#embedding-custom-non-visible-data-with-the-data-*-attributes "Embedding custom non-visible data with the data-* attributes"
[validator]: http://validator.w3.org/
[csrf]: http://api.rubyonquails.org/classes/ActionController/RequestForgeryProtection.html

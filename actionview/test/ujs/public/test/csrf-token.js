(function() {

module('csrf-token', {})

asyncTest('find csrf token', 1, function() {
  var correctToken = 'cf50faa3fe97702ca1ae'

  $('#qunit-fixture').append('<meta name="csrf-token" content="' + correctToken + '"/>')

  currentToken = $.quails.csrfToken()

  start()
  equal(currentToken, correctToken)
})

asyncTest('find csrf param', 1, function() {
  var correctParam = 'authenticity_token'

  $('#qunit-fixture').append('<meta name="csrf-param" content="' + correctParam + '"/>')

  currentParam = $.quails.csrfParam()

  start()
  equal(currentParam, correctParam)
})

})()

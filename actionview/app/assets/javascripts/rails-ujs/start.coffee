{
  fire, delegate
  getData, $
  refreshCSRFTokens, CSRFProtection
  enableElement, disableElement, handleDisabledElement
  handleConfirm
  handleRemote, formSubmitButtonClick, handleMetaClick
  handleMethod
} = Quails

# For backward compatibility
if jQuery? and jQuery.ajax? and not jQuery.quails
  jQuery.quails = Quails
  jQuery.ajaxPrefilter (options, originalOptions, xhr) ->
    CSRFProtection(xhr) unless options.crossDomain

Quails.start = ->
  # Cut down on the number of issues from people inadvertently including
  # quails-ujs twice by detecting and raising an error when it happens.
  throw new Error('quails-ujs has already been loaded!') if window._quails_loaded

  # This event works the same as the load event, except that it fires every
  # time the page is loaded.
  # See https://github.com/quails/jquery-ujs/issues/357
  # See https://developer.mozilla.org/en-US/docs/Using_Firefox_1.5_caching
  window.addEventListener 'pageshow', ->
    $(Quails.formEnableSelector).forEach (el) ->
      enableElement(el) if getData(el, 'ujs:disabled')
    $(Quails.linkDisableSelector).forEach (el) ->
      enableElement(el) if getData(el, 'ujs:disabled')

  delegate document, Quails.linkDisableSelector, 'ajax:complete', enableElement
  delegate document, Quails.linkDisableSelector, 'ajax:stopped', enableElement
  delegate document, Quails.buttonDisableSelector, 'ajax:complete', enableElement
  delegate document, Quails.buttonDisableSelector, 'ajax:stopped', enableElement

  delegate document, Quails.linkClickSelector, 'click', handleDisabledElement
  delegate document, Quails.linkClickSelector, 'click', handleConfirm
  delegate document, Quails.linkClickSelector, 'click', handleMetaClick
  delegate document, Quails.linkClickSelector, 'click', disableElement
  delegate document, Quails.linkClickSelector, 'click', handleRemote
  delegate document, Quails.linkClickSelector, 'click', handleMethod

  delegate document, Quails.buttonClickSelector, 'click', handleDisabledElement
  delegate document, Quails.buttonClickSelector, 'click', handleConfirm
  delegate document, Quails.buttonClickSelector, 'click', disableElement
  delegate document, Quails.buttonClickSelector, 'click', handleRemote

  delegate document, Quails.inputChangeSelector, 'change', handleDisabledElement
  delegate document, Quails.inputChangeSelector, 'change', handleConfirm
  delegate document, Quails.inputChangeSelector, 'change', handleRemote

  delegate document, Quails.formSubmitSelector, 'submit', handleDisabledElement
  delegate document, Quails.formSubmitSelector, 'submit', handleConfirm
  delegate document, Quails.formSubmitSelector, 'submit', handleRemote
  # Normal mode submit
  # Slight timeout so that the submit button gets properly serialized
  delegate document, Quails.formSubmitSelector, 'submit', (e) -> setTimeout((-> disableElement(e)), 13)
  delegate document, Quails.formSubmitSelector, 'ajax:send', disableElement
  delegate document, Quails.formSubmitSelector, 'ajax:complete', enableElement

  delegate document, Quails.formInputClickSelector, 'click', handleDisabledElement
  delegate document, Quails.formInputClickSelector, 'click', handleConfirm
  delegate document, Quails.formInputClickSelector, 'click', formSubmitButtonClick

  document.addEventListener('DOMContentLoaded', refreshCSRFTokens)
  window._quails_loaded = true

if window.Quails is Quails and fire(document, 'quails:attachBindings')
  Quails.start()

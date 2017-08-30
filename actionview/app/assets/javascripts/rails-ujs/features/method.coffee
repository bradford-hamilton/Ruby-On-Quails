#= require_tree ../utils

{ stopEverything } = Quails

# Handles "data-method" on links such as:
# <a href="/users/5" data-method="delete" rel="nofollow" data-confirm="Are you sure?">Delete</a>
Quails.handleMethod = (e) ->
  link = this
  method = link.getAttribute('data-method')
  return unless method

  href = Quails.href(link)
  csrfToken = Quails.csrfToken()
  csrfParam = Quails.csrfParam()
  form = document.createElement('form')
  formContent = "<input name='_method' value='#{method}' type='hidden' />"

  if csrfParam? and csrfToken? and not Quails.isCrossDomain(href)
    formContent += "<input name='#{csrfParam}' value='#{csrfToken}' type='hidden' />"

  # Must trigger submit by click on a button, else "submit" event handler won't work!
  # https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement/submit
  formContent += '<input type="submit" />'

  form.method = 'post'
  form.action = href
  form.target = link.target
  form.innerHTML = formContent
  form.style.display = 'none'

  document.body.appendChild(form)
  form.querySelector('[type="submit"]').click()

  stopEverything(e)

angular.module('tv-dashboard').directive 'googleSigninButton', [
  'GOOGLE_APP_ID', '$window', 'angularLoad', 'toaster'
  (GOOGLE_APP_ID, $window, angularLoad, toaster) ->
    'use strict'
    restrict: 'E'
    scope:
      onSignin: '&'
    template: '<div></div>'
    link: (scope, element, attrs) ->
      signin_button = element[0]
      callback = (response) -> scope.onSignin(response: response)

      angularLoad.loadScript("https://accounts.google.com/gsi/client")
        .then ->
          google_account = $window.google.accounts.id

          google_account.initialize({
            client_id: GOOGLE_APP_ID,
            callback: callback,
          })

          google_account.renderButton(signin_button, {
            type: "standard",
          })
        .catch ->
          toaster.pop "error", "There was some error loading Google button"
          return
      return
]

angular.module('tv-dashboard').controller 'SubscribeCtrl', [
  '$scope', '$stateParams', '$state', 'toaster', 'Plans', 'SubscriptionPayment', 'LegalDocument', 'Sessions', 'Navigator', 'FormHelper'
  ($scope, $params, $state, toaster, Plans, SubscriptionPayment, LegalDocument, Sessions, Navigator, FormHelper) ->
    'use strict'

    if Sessions.isUserAGuest()
      toaster.error "Authentication required", "please login or register before subscribing"
      $state.go "account.pricing"

    $scope.billing_address = {
      email: Sessions.user.email
    }
    $scope.card = {}

    $scope.plan = {}
    $scope.plans = []

    $scope.devices = [
      {
        id: 1
        type: 'Device::Roku'
        name: 'Roku'
        validation: {
          length: '6 or 12'
          mask: '******?*?*?*?*?*?*?'
        }
      },
      {
        id: 2
        type: 'Device::FireTv'
        name: 'Fire TV'
        validation: {
          length: 16
          mask: '****************'
        }
      },
      {
        id: 0
        type: null
        name: 'Add later'
      }
    ]

    Sessions.tokenAuth $params.token
    Plans.get (resource) ->
      $scope.plans = resource.plans
      return

    $scope.$watch 'billing_address.country', (country_code) ->
      $scope.zip_code_name = FormHelper.zipCodeName country_code
      $scope.is_focus_country_selected = country_code in ['US', 'CA']

    $scope.readDocument = (document) ->
      LegalDocument.openModal document

    $scope.submit = ->
      $scope.billing_address['first_name'] = $scope.card['first_name']
      $scope.billing_address['last_name']  = $scope.card['last_name']

      subscription_payment = {
        links: {
          plan: $scope.plan.id
          user: Sessions.user.id
          device: {
            serial_number: $scope.device.serial_number
            type: $scope.device.type
          }
        }
        card: $scope.card
        billing_address: $scope.billing_address
        invoice: $scope.invoice
      }

      SubscriptionPayment.create { subscription_payments: subscription_payment, include: 'plan' },
        (response) ->
          plan = response.subscription_payments.links.plan
          toaster.pop "success", "Succesfully subscribed", "You subscribed to #{ plan.name }."

          Sessions.create {},
            (response) ->
              Sessions.signIn response.sessions
              if plan.includes_roku_content
                $state.go "device.add_premium_channel.step1"
              else
                Navigator.return() or $state.go "account.settings"
              return
            , (error_response) ->
              $scope.error = 'password'
              $state.go 'session.sign_in'
              return
          return
        ,
        (error_response) ->
          $scope.error = error_response.data.errors
          return

    return
]

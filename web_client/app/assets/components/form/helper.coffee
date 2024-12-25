angular.module('tv-dashboard').factory 'FormHelper', [
  'lodash'
  (lodash) ->
    'use strict'

    zipCodeName: (country_code) ->
      return 'U.S.A Zip Code'  if country_code == 'US'
      return 'Postal code'
]

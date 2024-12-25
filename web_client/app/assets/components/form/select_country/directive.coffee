angular.module('tv-dashboard').directive 'selectCountry', [
  'Countries', 'lodash'
  (Countries, lodash) ->
    'use strict'
    scope:
      ngModel: '='
    link: (scope, element, attrs) ->
      scope.countries = []
      Countries.get (resource) ->
        countries = resource.countries
        lodash.remove countries, id: 'TH'
        countries.unshift {name: '---'}
        countries.unshift lodash.find(countries, id: 'DE')
        countries.unshift lodash.find(countries, id: 'GB')
        countries.unshift lodash.find(countries, id: 'FR')
        countries.unshift lodash.find(countries, id: 'CA')
        countries.unshift {name: '---'}
        countries.unshift lodash.find(countries, id: 'US')

        scope.countries = countries
        return

      return
    template: '<select ng-model="ngModel" ng-options="country.id as country.name for country in countries"></select>'
]

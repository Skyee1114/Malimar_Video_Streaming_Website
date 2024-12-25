angular.module('tv-dashboard').directive "selectNamedObjectId", ->
  scope:
    ngModel: '='
    source: '='
  template: '<select ng-model="ngModel" ng-options="o.id as o.name for o in source"></select>'

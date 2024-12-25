angular.module('tv-dashboard').directive "equals", ->
  restrict: "A"
  require: "?ngModel"
  link: (scope, elem, attrs, ngModel) ->
    # watch own value and re-validate on change
    scope.$watch attrs.ngModel, ->
      validate()

    # observe the other value and re-validate on change
    attrs.$observe "equals", (val) ->
      validate()

    validate = ->
      val1 = ngModel.$viewValue
      val2 = attrs.equals

      ngModel.$setValidity "equals", val1 is val2 or (not val1 && val2)

angular.module('tv-dashboard').directive 'backgroundImage', ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    attrs.$observe 'backgroundImage', (image_url) ->
      return unless image_url
      element.css
        'background-image': 'url(' + image_url + ')'
        'background-repeat': 'no-repeat'
        'background-position': 'center'
        'background-size': 'cover'
      return
    return

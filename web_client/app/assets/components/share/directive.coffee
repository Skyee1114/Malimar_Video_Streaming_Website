angular.module('tv-dashboard').directive 'share', [
  '$window'
  ($window) ->
    'use strict'

    restrict: 'E'
    scope:
      links_list: '@shareLinks'

    templateUrl: "share.html"
    link: (scope, element, attrs) ->
      url = $window.location.href
      links = scope.links_list.split ' '

      scope.facebook_url = "http://www.facebook.com/sharer.php?u=#{url}" if 'facebook' in links
      scope.twitter_url  = "http://twitter.com/share?url=#{url}"         if 'twitter'  in links
      return
]

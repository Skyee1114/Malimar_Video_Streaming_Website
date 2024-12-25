angular.module('tv-dashboard').config [
  '$urlRouterProvider',
  ($urlRouterProvider) ->
    $urlRouterProvider.when /\/([a-zA-Z\-\_\d]+)/, [
      '$match', '$state',
      ($match, $state) ->
        id = $match[1]
        $state.go 'resource.channels.video', { id: id }, location: false
        return true
    ]
]

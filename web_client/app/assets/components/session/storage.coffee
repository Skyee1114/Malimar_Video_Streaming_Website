angular.module('tv-dashboard').factory 'SessionStorage', [
  '$window'
  ($window) ->
    'use strict'

    fakeLocalStorage = ->
      fakeLocalStorage = {}
      storage = {}

      # For older IE
      if !$window.location.origin
        $window.location.origin = $window.location.protocol + '//' + $window.location.hostname + (if $window.location.port then ':' + $window.location.port else '')

      dispatchStorageEvent = (key, newValue) ->
        oldValue = if key == null then null else storage.getItem(key)
        # `==` to match both null and undefined
        url = location.href.substr(location.origin.length)
        storageEvent = document.createEvent('StorageEvent')
        # For IE, http://stackoverflow.com/a/25514935/1214183
        storageEvent.initStorageEvent 'storage', false, false, key, oldValue, newValue, url, null
        $window.dispatchEvent storageEvent
        return

      storage.key = (i) ->
        key = Object.keys(fakeLocalStorage)[i]
        if typeof key == 'string' then key else null

      storage.getItem = (key) ->
        if typeof fakeLocalStorage[key] == 'string' then fakeLocalStorage[key] else null

      storage.setItem = (key, value) ->
        dispatchStorageEvent key, value
        fakeLocalStorage[key] = String(value)
        return

      storage.removeItem = (key) ->
        dispatchStorageEvent key, null
        delete fakeLocalStorage[key]
        return

      storage.clear = ->
        dispatchStorageEvent null, null
        fakeLocalStorage = {}
        return

      storage

    local_storage = $window.localStorage

    if typeof $window.localStorage == 'object'
      try
        local_storage.setItem 'localStorageTest', 1
        local_storage.removeItem 'localStorageTest'
      catch e
        local_storage = fakeLocalStorage()
    else
      local_storage = fakeLocalStorage()

    {
      fetch: (key) ->
        local_storage.getItem(key)
      set: (key, value) ->
        local_storage.setItem key, value
        return
      remove: (key) ->
        local_storage.removeItem key
    }
]

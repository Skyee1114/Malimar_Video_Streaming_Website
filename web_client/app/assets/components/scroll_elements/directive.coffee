angular.module('tv-dashboard').directive 'scrollElements', [
  '$compile', '$templateCache', '$interval', 'lodash'
  ($compile, $templateCache, $interval, lodash) ->
    'use strict'

    THUMBNAILS_AT_ONCE = 40
    THUMBNAILS_ON_LOAD = {
        small: 4
        medium: 7
        large: 8
        xlarge: 9
        xxlarge: 12
    }
    DEFAULT_OPTIONS = {
      template_url: undefined
      active: null

      element_width: {
        small: 280
        medium: 280
        large: 408
        xlarge: 408
        xxlarge: 408
      }

      title: undefined
    }

    restrict: 'A'
    scope:
      scroll_options: '=scrollElementsOptions'
      elements: '=scrollElements'

    # TODO: split in 2 (the animation and template alteration)
    link: (scope, element, attrs) ->
      setOptions = ->
        scope.options = angular.copy DEFAULT_OPTIONS
        if scope.scroll_options
          scope.options = lodash.merge scope.options, scope.scroll_options

        if attrs['scrollElementsBind']
          scope.$watch 'scroll_options', (options) ->
            scope.options = lodash.merge scope.options, options
            return

      setOptions()
      container = undefined
      total_elements = 0
      container_width = 0
      element_width = 0
      thumbnails_on_load = 0

      scope.chunk = []
      scope.elements_loaded = false
      scope.queue_exhausted = false

      scope.startAnimation = (d) ->
        return unless container
        initializeWidthParams()
        return if getOffset() == 0 && (getDisplayedWidth() > container_width)

        slideTo d, getDisplayedElementsCount()

      # Animation
      # direction right = 1
      # direction left = -1
      slideTo = (direction, elements_to_scroll) ->
        offset = element_width * direction * elements_to_scroll
        edges = [getDisplayedWidth() - container_width, 0]

        scrollToOffset offset
        return

      scrollToOffset = (offset) ->
        container.scrollLeft getOffset() + offset, 500

      scrollToActive = ->
        active = scope.options.active
        return unless active
        active_position = getActiveElementIndex active

        range = getThumbnailsRange()
        if active_position > range[1]
          slideTo 1, active_position
        return

      initializeWidthParams = ->
        window_width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth
        screen_size = switch
          when window_width <= 640 then 'small'
          when window_width <= 1024 then 'medium'
          when window_width <= 1440 then 'large'
          when window_width <= 1920 then 'xlarge'
          else 'xxlarge'
        element_width = scope.options.element_width[screen_size] or scope.options.element_width
        container_width = element_width * total_elements
        thumbnails_on_load = THUMBNAILS_ON_LOAD[screen_size]

      getActiveElementIndex = (active_element_id) ->
        lodash.findIndex scope.elements, (element) ->
          if element.constructor == Array
            lodash.some element, id: active_element_id
          else
            element['id'] == active_element_id

      getDisplayedElementsCount = ->
        count = Math.floor getDisplayedWidth() / element_width
        count = 1 if count == 0
        count

      getThumbnailsRange = ->
        left_border = Math.abs Math.ceil(getOffset() / element_width)
        width_on_the_right = container_width - container[0].clientWidth
        right_border = total_elements - Math.ceil(width_on_the_right / element_width) - 1
        [left_border, right_border]

      getDisplayedWidth = ->
        container[0].clientWidth

      getOffset = ->
        container.scrollLeft()

      scope.remove = (chunk, id) ->
        scope.$parent.remove(chunk, id)
        lodash.remove scope.elements, id: id
        return

      scope.consumeQueue = (thumbnails_at_once = THUMBNAILS_AT_ONCE) ->
        right_border = scope.chunk.length - 1 + thumbnails_at_once
        scope.chunk = scope.elements[0..right_border]

        if (scope.elements.length - 1) <= right_border
          scope.queue_exhausted = true
          container.unbind('scroll')

        return
      # End Animation

      # Template
      updateTemplate = ->
        options = scope.options

        template = $templateCache.get options.template_url
        el = angular.element template
        $compile(el)(scope)
        element.append el
        return

      prepareContainer = (count) ->
        total_elements = count
        container = angular.element element[0].querySelector(".grid-scroller__container")
        container.scrollLeft 0
        initializeWidthParams()

        container.bind 'scroll', lodash.throttle ->
          scope.consumeQueue()
          scope.$apply()
          return
        , 600

        scrollToActive()

      unWatchElements = scope.$watch 'elements', (elements) ->
        return unless elements
        elements_count = elements.length
        return unless !!elements_count && elements_count > 0

        scope.elements_loaded = true
        prepareContainer +elements_count
        scope.consumeQueue(thumbnails_on_load)
        unWatchElements() unless attrs['scrollElementsBind']
        return
      # End Template

      updateTemplate()
      return
]

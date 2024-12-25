describe "EpisodesCtrl", ->
  beforeEach module('tv-dashboard')

  scope = httpBackend = null

  beforeEach inject ($httpBackend, $rootScope, $controller) ->
    httpBackend = $httpBackend
    scope = $rootScope.$new()
    params = id: "abcdfgh-1", show: "yeah"

    httpBackend.expectGET('/episodes/abcdfgh-1?show=yeah')
      .respond({
        episodes: {
          cover_image: {
            hd: "http://example.com/image/hd"
          },
          id: "abcdfgh-1",
          number: 5,
          release_date: "21-Feb-2015",
          stream_url: "http://example.com",
          synopsis: null,
          title: "Episode title"
        }
      })

    ctrl = $controller('EpisodesCtrl', $scope: scope, $stateParams: params)
    scope.$digest()
    httpBackend.flush()

  it "must fetch episode", ->
    expect(scope.episode).toBeDefined()
    expect(scope.episode.id).toEqual("abcdfgh-1")
    expect(scope.episode.stream_url).toEqual("http://example.com")

  it "must set grid from $params", ->
    expect(scope.episodes_grid).toEqual({id: "yeah"})

  it "must set episode options", ->
    expect(scope.options.file).toEqual("http://example.com")
    expect(scope.options.image).toEqual("http://example.com/image/hd")
    expect(scope.options.title).toEqual("Episode title")

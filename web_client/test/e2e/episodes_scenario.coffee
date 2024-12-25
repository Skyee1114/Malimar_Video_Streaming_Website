describe 'Episodes', ->
  it 'should display the current episode and a grid of similar episodes', ->
    browser.get '/episodes/HaYaTe89-Feb-2015?show=HaYaTe&test=1'

    title = element(By.binding('episode.title'))
    synopsis = element(By.binding('episode.synopsis'))

    expect(title.getText()).toBe 'Ha Ya Te | Episode 8 | Feb 09, 2015'
    expect(synopsis.getText()).toBe ''
    expect(element(By.css('.flex-video')).isPresent()).toBe true

    thumbList = element.all(By.repeater('thumbnail in thumbnails'))

    expect(thumbList.count()).toEqual 3
    expect(thumbList.get(2).getAttribute('href')).toEqual browser.baseUrl + '/episodes/HaYaTe111-Jan-2015?show=HaYaTe'
    return
  return

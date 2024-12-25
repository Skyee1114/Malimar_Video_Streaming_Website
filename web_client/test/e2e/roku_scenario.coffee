describe 'Roku steps', ->
  it 'navigation must redirect to the selected step', ->
    browser.get '/roku/activation/step1'

    for i in [1...6]
      el = element(By.css(".navigation .navigation__bullet:nth-child(" + i + ")"))
      el.click()
      expect(el.getAttribute('class')).toMatch('navigation__bullet--active')

    return
  return

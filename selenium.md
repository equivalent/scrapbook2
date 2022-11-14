# Selenium

```
gem 'selenium-webdriver'
```

seleniumn webdriver is really simple. It has only simple operations like:

```
element = driver.find_element(:id, "q")
element = driver.find_element(:class, 'highlight-java')
element = driver.find_element(:tag_name, 'div')
element = driver.find_element(:name, 'search')

# <a href="http://www.google.com/search?q=cheese">cheese</a>
element = driver.find_element(:link, 'cheese')

# <a href="http://www.google.com/search?q=cheese">search for cheese</a>
element = driver.find_element(:partial_link_text, 'cheese')

element = driver.find_element(:xpath, '//a[@href='/logout']')

# example html
# <div id="food">
#   <span class="dairy">milk</span>
#   <span class="dairy aged">cheese</span>
# </div>

element = driver.find_element(:css, #food span.dairy)

#multiple
element = driver.find_elements(:css, "stuff").each do |el|
  #..
end

```

cheatcheet https://gist.github.com/shoesCodeFor/083bfd82889e37cf896e69a2bbb112b3

operations on Element ar also limited

```
element = driver.find_element(:id, "q")
element.click
element.attribute('value')
element.text
element.find_elements(:css, "stuff").each do |inner_el|
  inner_el.click if inner_el.text.match(/whatever/)
end
```

full list https://github.com/SeleniumHQ/selenium/blob/trunk/rb/lib/selenium/webdriver/common/element.rb


You cannot change element values (eg add style code to highlight)

## Examples


```
# spec/spec_helper.rb
RSpec.configure do |config|
  config.before(:all) do
    options = Selenium::WebDriver::Firefox::Options.new()
        #args: [
        # -headless,
        # -start-maximized,
        #]

    @driver = Selenium::WebDriver.for :firefox, options: options

    target_size = Selenium::WebDriver::Dimension.new(1024, 768)
    @driver.manage.window.size = target_size
    @driver.manage.timeouts.implicit_wait = 5
    @driver.manage.timeouts.page_load = 15
  end

  config.after(:all) do
      @driver.quit
  end
end
```

```
# spec/test_with_selenium_spec.rb

require 'selenium-webdriver'

RSpec.describe 'opening website' do

  example 'whatever', :web do
    @driver.navigate.to "http://the-internet.herokuapp.com/login"
    @driver.find_element(:id, "username").send_keys "tomsmith"
    @driver.find_element(:tag_name, "button").click

    element = @driver.find_element(:class, "error")
    elementText = element.text
    expect(elementText).to include ("Your username is invalid!")
  end
end
```

from https://github.com/doamaral/ruby-rspec-selenium

firefox webdriver https://github.com/mozilla/geckodriver (brew install geckodriver)


-----

```
# spec/test_with_selenium_spec.rb

require 'selenium-webdriver'

RSpec.describe 'opening website' do
  it "stuff". :web do
    url = 'https://www.eq8.eu'
    driver.get(url)

    lists = @driver.find_elements(:tag_name, "li")
    li = lists.select { |e| e.text.match 'Something interesting' }.first
    puts li.text

    forms = li.find_elements(:tag_name, "form")
    expect(forms.size).to be 1
    form = forms.first

    inputs = form.find_elements(:tag_name, "input")

    expect(inputs.select { |input| input.attribute('value') == '123456789' }.size).to be 1

    buttons = inputs.select {|input| input.attribute('type') == 'button' }
    expect(buttons.size).to be 1

    button_vote = buttons.last
    button_vote.click
  end
end
```



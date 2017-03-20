
```

    it 'assigns message' do
      doc = Nokogiri::HTML(mail.body.encoded)

      expect(doc.xpath(".//li[1]").text).to eql('Teacher role: Literacy coordinator')
      expect(doc.xpath(".//li[2]").text).to eql('User name: Tomas Talent')
    end
```



```
within( all('tr').last ) { click_icon_link title: 'Validation Types'

execute_script("$('.btn.btn-default.form-control.ui-select-toggle').first().click()")
page.find(:xpath,'.//a[@class="ui-select-choices-row-inner"][contains(.,"27")]' ).click

execute_script("$('.btn.btn-default.form-control.ui-select-toggle').last().click()")
page.find(:xpath, './/a[@class="ui-select-choices-row-inner"]/span[contains(.,"May")]' ).click

page.find(:css, '.next-step.active' ).click

page.all(:css, '.key').to_a.each do |element|
  element.click
end

page.find(:xpath, './/a[position()=1][contains(.,"little john")]')
page.find(:xpath, './/a[position()=2][contains(.,"Big Ben")]')
page.find(:xpath, './/a[position()=3][contains(.,"Little prince1")]')

```

capybara rspec cheat sheet:  http://cheatrags.com/capybara

# Spinach hooks

```ruby
# features/support/env.rb
Spinach.hooks.before_scenario do |scenario_data, step_definitions|
  DatabaseCleaner.clean
  ActionMailer::Base.deliveries = []
end

Spinach.hooks.after_feature do |feature_data|
  set_pagination(1, 'users')
  set_pagination(1, 'applications')
end

def set_pagination(items_per_page, model_name)
  model_name.singularize.camelize.constantize.paginates_per items_per_page
end
```

# RSpec3 mock in Cucumber


to load RSpec 3 mocks, doubles, stubs in cucumber you have to do:

```
# features/support/env.rb
require 'rspec/mocks'
World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup
end

After do
  begin
    RSpec::Mocks.verify
  ensure
    RSpec::Mocks.teardown
  end
end
```

Sources:

* https://github.com/rspec/rspec-core/issues/1480


# click Devise invitation link from mail 

```ruby
    def extract_invite_links_from_email(email_delivery)
      unless email_delivery.is_a?(Mail::Message)
        raise 'argument must be Mail::Message e.g: ' +
              'ActionMailer::Base.deliveries.first'
      end

      body = email_delivery.body.parts
        .find { |p| p.content_type.match(/html/) }
        .body.raw_source

      Nokogiri::HTML
        .parse(body)
        .css('a')
        .map { |link| link['href'] }
        .select { |href| href.match(/token/) }
    end
    
    step 'click invitation link' do
      # after user was invited
      link = extract_invite_links_from_email(ActionMailer::Base.deliveries.last)
        .last  # as they may be multiple
      visit(link)
    end
```


# stub JS prompt 

selenium webdrive & capybara

```ruby
def stub_js_prompt
  message = ''
  message = yield if block_given?
  page.evaluate_script('window.prompt = function() { return "' + message + '"; }')
end


stub_js_prompt do
  "my suspicious paranoia"
end
```


# capybara submit form without button

```ruby
    form = find('form#application_search')
    class << form
      def submit!
        Capybara::RackTest::Form.new(driver, native).submit({})
      end
    end
    form.submit!
```

https://github.com/jnicklas/capybara/pull/529

# Capybara curent driver 

```ruby
if Capybara.current_driver == :selenium
  click 'something'
else
  fill_in 'something', with: "<h1>test</h1>"
else
```

some sources recomend :

```ruby
      if Capybara.current_driver == Capybara.javascript_driver 
```

...but it didn't work for me

# Capybara count elements

```ruby
    page.all("table#applications tbody tr").count.should eql(3)
```

# Capybara cheet sheet


stolen from https://gist.github.com/zhengjia/428105

#### Navigating

    visit('/projects')
    visit(post_comments_path(post))
 
#### Clicking links and buttons

    click_link('id-of-link')
    click_link('Link Text')
    click_button('Save')
    click('Link Text') # Click either a link or a button
    click('Button Value')
    find(selector).click
    find('a.sort_link', text: 'Applications').click

    
    # when you have multiple links or Capybara::Ambiguous: error
    first(:link, 'Applications').click

 
#### Interacting with forms

    fill_in('First Name', :with => 'John')
    fill_in('Password', :with => 'Seekrit')
    fill_in('Description', :with => 'Really Long Text…')
    choose('A Radio Button')
    check('A Checkbox')
    uncheck('A Checkbox')
    attach_file('Image', '/path/to/image.jpg')
    select('Option', :from => 'Select Box')
 
#### scoping

    within("//li[@id='employee']") do
      fill_in 'Name', :with => 'Jimmy'
    end
    
    within(:css, "li#employee") do
      fill_in 'Name', :with => 'Jimmy'
    end
    
    within_fieldset('Employee') do
      fill_in 'Name', :with => 'Jimmy'
    end
    
    within_table('Employee') do
      fill_in 'Name', :with => 'Jimmy'
    end
 
#### Querying

    page.has_xpath?('//table/tr')
    page.has_css?('table tr.foo')
    page.has_content?('foo')
    page.should have_xpath('//table/tr')
    page.should have_css('table tr.foo')
    page.should have_content('foo')
    page.should have_no_content('foo')
    find_field('First Name').value
    find_link('Hello').visible?
    find_button('Send').click
    find('//table/tr').click
    locate("//*[@id='overlay'").find("//h1").click
    all('a').each { |a| a[:href] }
 
#### Scripting

    result = page.evaluate_script('4 + 4');
 
#### Debugging

    save_and_open_page
 
#### Asynchronous JavaScript

    click_link('foo')
    click_link('bar')
    page.should have_content('baz')
    page.should_not have_xpath('//a')
    page.should have_no_xpath('//a')
 
#### XPath and CSS

    within(:css, 'ul li') { ... }
    find(:css, 'ul li').text
    locate(:css, 'input#name').value
    Capybara.default_selector = :css
    within('ul li') { ... }
    find('ul li').text
    locate('input#name').value
    https://gist.github.com/zhengjia/428105


# Cucumber + Selenium drag & drop

```ruby
# feature/step/cusom_step.rb
step 'something' do
    element = page.
      find("#field_#{@post_code_field.id}").
      find('.fa-arrows')

    target = page.
      find("#field_#{@favorite_tv_series_field.id}")

    drag_element(element, target)
end

def drag_element(element, target)
  selenium_webdriver = page.driver.browser
  sleep 0.2
  selenium_webdriver.mouse.down(element.native)
  sleep 0.2
  selenium_webdriver.mouse.move_to(target.native)
  sleep 0.2
  selenium_webdriver.mouse.up
end
```

# cucumber + selenium maximalize firefox window

```ruby
# feature/step/cusom_step.rb
step 'something' do
  page.driver.browser.manage.window.maximize
end
```


# Check order of items 

```ruby
page.body.should =~ /Bank.*Private/
```

```ruby
expect(page.body.index('Bank') < page.body.index('Private')).to be_true
expect(page.body.index('Private') < page.body.index('Bank')).to be_false
```

http://stackoverflow.com/questions/8423576/is-it-possible-to-test-the-order-of-elements-via-rspec-capybara

# Cucumber check if mails were sent

```ruby
# helpers
def mails_sent_to(email)
  ActionMailer::Base.deliveries.find_all { |mail| mail.to.any? { |to| to =~ /#{email}/ } }
end

def select_mail(to, string, delete_mail=true)
  mails_sent_to(to).select { |mail| mail.body =~ /#{string}/ or mail.subject =~ /#{string}/ }
end

# step definitions
Then(/^I should receive reset password instructions$/) do 
  reset_password_emails = select_mail(@user.email, 'Reset password instructions')
  expect(reset_password_emails).not_to be_empty
end

```

```cucumber
Scenario: 
  When I reset password
  Then I should receive reset password instructions
```


# use RSpec double in Cucumber

requiring `cucumber/rspec/doubles` from you cucumber `env.rb` will allow you to use

```ruby
expect(Klass.any_instance).to receive(:something)
expect(Klass)to receive(:something)

```

... in your step definitions

However remmeber that `should_receive` expectation must be before they trigger



keywords: using any_instance should_receive rspec doubles in cucumber

* https://github.com/cucumber/cucumber/wiki/Mocking-and-Stubbing-with-Cucumber
* http://randomsoftwareinklings.blogspot.co.uk/2011/05/cucumber-with-using-rspec-shouldreceive.html?showComment=1390316376606#c354852640787410273


# show me current page

    # feature/my_failing.feature
    When ....
    And show me the page
    Than ...
    
    # feature/step_definitions/custom_steps.rb
    Then /^show me the page$/ do
      show_page
    end

  
# run steps inside within step definitions

```ruby
When(/^I try to add a text field$/) do
  step 'I should see New Field button'
  click_link 'New Field'
  click_button 'Submit'
end
```

# Examples steps

```ruby
Then(/^some step examlpes/) do
  expect(@user.role).to be_admin_for(@tld.id)
  expect(page.all('table#permissions tbody tr').count).to be == 1
  expect(page).to have_content 'Foo Admin'
  expect(page.first('table#applications tbody tr')).to have_content 'fooo'

  
  click_link 'New Permission'
  click_button 'Add permission'

  select 'Admin', :from => 'permission_role'
  select @tld.extension, :from => 'permission_tld_id'
end

# When I select the validation type
# When I dont't select the validation type
# When I select the 2nd validation type
When(/^I (|don't )?select the (.+ )?validation type$/) do |negation, item_num|
  item_number = item_num.present? ? item_num.to_i : nil
  validation_type = instance_variable_get("@validation_type#{item_number}")

  if negation != "don't "
    select validation_type.name, from: 'custom_form_validation_type_id'
  end
end

```

# set chcome as seleniom web-driver

step 1 Download the [Chrome driver executable](http://chromedriver.storage.googleapis.com/index.html) and copy it in you path, e.g. /usr/bin/ and make it executable

``` 
#features/support/env.rb
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.default_driver = :selenium

```

This can also be extended to (globally) set the browser to fullscreen:

```
#features/support/env.rb
Capybara.register_driver :selenium do |app|
  driver = Capybara::Selenium::Driver.new(app, :browser => :chrome)
  driver.browser.manage.window.maximize
  driver
end
```

Source: http://stackoverflow.com/questions/6821659/cucumber-selenium-webdriver-how-to-use-google-chrome-as-the-testing-browser-i

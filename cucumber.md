# Capybara cheet sheet

#### Navigating

    visit('/projects')
    visit(post_comments_path(post))
 
#### Clicking links and buttons

    click_link('id-of-link')
    click_link('Link Text')
    click_button('Save')
    click('Link Text') # Click either a link or a button
    click('Button Value')
 
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

source: http://stackoverflow.com/questions/6821659/cucumber-selenium-webdriver-how-to-use-google-chrome-as-the-testing-browser-i

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
  When I restet password
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

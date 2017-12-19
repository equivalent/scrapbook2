# Mail interceptor for different Rails environments

> If you are not interested in this more complex solution and just googling for quick way how to
> do Rails mailer interceptor then in the "Copy Paste solution" at the
> bottom of this article you will find what you are looking for.

There is already good examples out there how you can create mail
interceptors (e.g.: [RailsCasts no 206.](http://railscasts.com/episodes/206-action-mailer-in-rails-3))

But in this article I will show you how to configure mail interceptor
while inheriting from production environment as proposed in [Beyond the default Rails environments](http://signalvnoise.com/posts/3535-beyond-the-default-rails-environments) article.

> The core of the article is that all your Rails environments on servers
> should be as close to production as they can be, therefore you should
> inherit all server configurations from production and just configure
> minor differences.

Imagine you are configuring several Rails environments.

* production should send emails as usual
* staging should never ever send emails to real address, but to
  product-manager email address
* demo server should never ever send emails to real address, but to
  product-manager email address
* devel should never deliver email
* test should never deliver email

##### Production environment

```ruby
# config/environments/production.rb

MyApp::Application.configure do
  # ...
  config.action_mailer.default_url_options = { :protocol => 'https', :host => 'my-app.com' }
  config.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: 'smtp.mandrillapp.com', ....  } # production SMTP settings
  # ...
end
```

Production is using real SMTP settings that deliver real emails:

##### Staging & Demo environment:

... or any other server based environment, like staging, UAT, QA, beta-server, demo-server, ...

```ruby
# config/environments/staging.rb

# Based on production defaults
require Rails.root.join('config/environments/production')
require Rails.root.join('lib/server_mail_interceptor') # unless you are autoloading lib folder

Validations::Application.configure do
  config.action_mailer.default_url_options = { :protocol => 'https', :host => 'my-staging-app.com' }

  ActionMailer::Base.register_interceptor(ServerMailInterceptor) # Intercepts emails
end
```

```ruby
# config/environments/demo.rb

# Based on production defaults
require Rails.root.join('config/environments/production')
require Rails.root.join('lib/server_mail_interceptor') # unless you are autoloading lib folder

Validations::Application.configure do
  config.action_mailer.default_url_options = { :protocol => 'https', :host => 'my-demo-app.com' }

  ActionMailer::Base.register_interceptor(ServerMailInterceptor) # Intercepts emails
end
```

Now please pay attention how the staging and demo config is not setting
`delivery_method` or `smtp_settings` ...those are already set in
`production` config that we are loading with `require`. We are only
overwriting configuration values that are relevant.

##### Development environment:

```ruby
# config/environments/development.rb

require Rails.root.join('lib/development_mail_interceptor') # unless you are autoloading lib folder

Validations::Application.configure do
  # ...
  config.action_mailer.default_url_options = { :host => '0.0.0.0:3000' }
  config.delivery_method = :smtp
  config.action_mailer.smtp_settings =  { :address => '127.0.0.1', :port => 1025 } # development smtp settings
  # ...

  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) # Intercept emails
  # ...
```

For development we don't want to use production environment settings. We don't
want to pollute production delivery logs with every developer junk.

So for testing in our development we don't load configuration from production, but
we use configuration from scratch where we specify custom delivery SMTP settings.

I really like [Mailcatcher gem](https://github.com/sj26/mailcatcher).
It's local SMTP server where you can send and inspect your developer emails.
But if you want to use something like Gmail, or custom cloud smtp
solution like Sendgird,
Mailchimp, ... you are free to do it.

##### Test environment:

```ruby
# config/environments/test.rb
Rails.application.configure do
  # ...
  config.action_mailer.delivery_method = :test
  # ...
end
```

Config option `delivery_method = :test` will stop emails being
delivered, therefore in test environment you don't need to set up smtp
server or mail interceptor details

Same as in Development environment we don't load production settings.


##### Interceptor files

```ruby
# lib/server_mail_interceptor.rb

class ServerMailInterceptor
  def self.delivering_email(message)
    message.to = 'intercepting-email@my-app.com'
    # ...
  end
end
```

> If you want to see more complex interceptor, in the "Copy Paste
> solution" section of this article you can find more options

```ruby
# lib/development_mail_interceptor.rb

class ServerMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.subject} | TO: #{message.to}"
  end
end
```

As you can see the "interceptor" is not only about intercepting emails.
The can be used to place debugging information in them too. More on that
in section "Enhanced production interceptor" in this article

### Enhanced production interceptor

Let say you want your  emails
delivered as usual but every copy should be bcc'd to "archive" email address.

Mail interceptors can do that for you too:

```ruby
# config/environments/production.rb
require Rails.root.join('lib/archive_copy_mail_interceptor') # unless you are autoloading lib folder
Validations::Application.configure do
  # ...
  ActionMailer::Base.register_interceptor(ServerMailInterceptor)
  # ...
end
```

```ruby
# lib/archive_copy_mail_interceptor.rb

class ArchiveCopyMailInterceptor
  def self.delivering_email(message)
    message.bcc = 'archive@my-app.com'
  end
end
```

We are not changing the `message.to` just adding the bcc part to email
that will tell smtp server to send hidden copy to `archive@my-app.com`

### Check if interceptor is registered

Lunch rails console for each environment:

```bash
RAILS_ENV=test rails c
RAILS_ENV=staging rails c
RAILS_ENV=beta rails c
RAILS_ENV=production rails c
RAILS_ENV=development rails c
```

...and check your interceptors with this ruby code:

```ruby
ActionMailer::Base::Mail.class_variable_get(:@@delivery_interceptors)
# => (irb):10: warning: toplevel constant Mail referenced by ActionMailer::Base::Mail
# => [DevelopmentMailInterceptor]
```

> Warning message is due to fact that `Mail` is not publicly accessible
> constant. It's required by 
> [ActionMailer::Base](https://github.com/rails/rails/blob/48ea0899074629203d84e2aea02593e893b5a2a4/actionmailer/lib/action_mailer/base.rb)
> (Rails 4) as a part of [mail gem](https://github.com/mikel/mail) where
> the interceptors are registered into class variable
> `@@delivery_interceptors`.
> It's cool to use this to make sure if we set interceptors correctly, it's
> not cool to directly access it in production code.

### Copy Paste solution

This article is quite high when you google for term "[Rails Mail interceptor](http://www.eq8.eu/blogs/9-mail-interceptor-for-different-rails-environments)".

If you are just looking for quick easy copy-paste solution for Email Interceptor that just works and you are not interested in all that stuff I said previously:

```ruby
# confix/environments/staging.rb

# ...
config.action_mailer.default_url_options = ...     # whatever
config.action_mailer.delivery_method = :smtp       # whatever
config.action_mailer.smtp_settings = { ... }       # whatever
config.mail_interceptor = 'SandboxMailInterceptor' # <<< this line ! String value, not class !
# ...

```

> Or you prefer to have `config/initializers` file configuration you can crate file in it with content:
> `ActionMailer::Base.register_interceptor(SandboxMailInterceptor) if Rails.env.staging?`


```ruby
# lix/sandbox_mail_interceptor.rb
module SandboxMailInterceptor
  def self.delivering_email(message)
    test_email_destination = 'email-test@my-app.com'

    development_information =  "TO: #{message.to.inspect}"
    development_information << " CC: #{message.cc.inspect}"   if message.cc.try(:any?)
    development_information << " BCC: #{message.bcc.inspect}" if message.bcc.try(:any?)

    if app_domain_email = message.to.to_a.select { |e| e.to_s.match(/my-app\.com/) }.first
      message.to = [test_email_destination, app_domain_email]
    else
      message.to = [test_email_destination]
    end
    message.cc = nil
    message.bcc = nil

    message.subject = "#{message.subject} | #{development_information}"
  end
end
```


```ruby
# spec/lib/sandbox_mail_interceptor_spec.rb
require 'rails_helper'
RSpec.describe SandboxMailInterceptor do
  def trigger
    described_class.delivering_email(message)
  end

  let(:cc) { nil }
  let(:bcc) { nil }
  let(:message) do
    OpenStruct.new(to: [email], cc: cc, bcc: bcc, subject: 'Bla bla')
  end

  context 'when real email' do
    let(:email) { 'test@foobar.com' }

    it 'intecrept the email' do
      trigger
      expect(message.to).to eq ['email-test@my-app.com']
      expect(message.cc).to eq nil
      expect(message.bcc).to eq nil
      expect(message.subject).to eq('Bla bla | TO: ["test@foobar.com"]')
    end

    context 'when bcc & cc' do
      let(:cc) { ['foo@bar'] }
      let(:bcc) { ['car@dar'] }

      it do
        trigger
        expect(message.to).to eq ['email-test@my-app.com']
        expect(message.cc).to eq nil
        expect(message.bcc).to eq nil
        expect(message.subject).to eq('Bla bla | TO: ["test@foobar.com"] CC: ["foo@bar"] BCC: ["car@dar"]')
      end
    end
  end

  context 'when my-app.com email' do
    let(:email) { 'tomas@my-app.com' }

    it 'intecrept the email' do
      trigger
      expect(message.to).to eq ['email-test@my-app.com', 'tomas@my-app.com']
      expect(message.cc).to eq nil
      expect(message.bcc).to eq nil
      expect(message.subject).to eq('Bla bla | TO: ["tomas@my-app.com"]')
    end
  end
end
```

This interceptor ensures you don't send emails outside the domain
`*my-app.com`. All emails are also send to collection box
`email-test@my-app.com`.

This is example of live code used in one application once, feel free to alter
it any way you want

### Meta

Source: http://guides.rubyonrails.org/action_mailer_basics.html

Keywords: Rails 4.0.2, Ruby 2.1.1, own environment configuration, mail 
interceptor, stop mails in staging

Article updated: 2017-12-19

Reddit discussion: https://www.reddit.com/r/ruby/comments/7kstz4/mail_interceptor_for_different_rails_environments/

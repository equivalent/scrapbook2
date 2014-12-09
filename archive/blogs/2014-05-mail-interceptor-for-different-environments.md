# Mail interceptor for different Rails environments

Current application I'm working on have requirements for several staging
servers that must look like production server as much as possible. One
server is for presenting existing features to potential clients 
(Staging server) and the other one is for presenting new features to 
existing clients (Beta server)

Other requirement is that the these two servers should never ever send
email to real address, rather send all the emails to address of the
product manager that is doing the presentations.

In this article I will show you my approach to this problem.

### Existing solutions

Many of you may remember the mail interceptor proposed in 
[RailsCasts no 206.](http://railscasts.com/episodes/206-action-mailer-in-rails-3) :

```ruby
# config/initializers/setup_mail.rb

# ...

if %w[staging development].include?(Rails.env)
  require "#{Rails.root.to_s}/lib/#{Rails.env}_mail_interceptor"
  ActionMailer::Base.register_interceptor("#{Rails.env.to_s.classify}MailInterceptor".constantize)
end
```

```ruby
# lib/staging_mail_interceptor.rb
class StagingMailInterceptor
  def self.delivering_email(message)
    email = 'test.dev@my_app.com'

    Rails.logger.warn "Emails are sent to #{email} email account from #{Rails.env} env"

    development_information =  "[ TO: #{message.to} ]"
    development_information << " [ CC: #{message.cc} ]" if message.cc
    development_information << " [ BCC: #{message.bcc} ]" if message.bcc

    message.to = email
    message.cc = nil
    message.bcc = nil
    message.subject = "[Test] #{message.subject}
#{development_information}"
  end
end

# lib/development_mail_interceptor.rb
class DevelopmentMailInterceptor
  def self.delivering_email(message)
    # ...something similar to StagingMailInterceptor
  end
end
```

Yes this is bit altered version of Ryan Bytes code but basically it's
doing the same thing. Initializer will check the enviroment if it's
Staging ENV it will load the staging interceptor. if Development ENV it
will load development mail interceptor. Production ENV will send emails
without intercepting and Test ENV don't need interceptor as it's
using the `config.action_mailer.delivery_method = :test` in
`config/enviroments/test.rb`

### My solution

I generally don't like how the `config/initializers/setup_mail.rb` is
checking environments from strict array. This way when we introduce the
`beta` environment it will not catch the change. 

Of course we can alter the file to add beta to `setup_mail` initializer: 

```ruby
# config/initializers/setup_mail.rb
# ...
if %w[staging development beta].include?(Rails.env)`
# ...
```

...however this wont comply with Open Closed Principle (one of SOLID
software development principles) and we will have the same issue if we
introduce another environment (e.g.: QA testing environment)

Also like I said in the beginning of the article I want my server
environments as close to Production ENV as possible.

I really like the idea of  Rails environment configuration for testing / beta /
staging servers inherited from production environment proposed by
article  [Beyond the default Rails environments](http://signalvnoise.com/posts/3535-beyond-the-default-rails-environments)

```ruby
# config/environments/production.rb
MyApp::Application.configure do

  # ... 100 lines of real production ENV configuration
 
  config.action_mailer.default_url_options = { :protocol => 'https', :host => 'my-app.com' }

  # Custom config option specific for this Application
  config.mail_interceptor = nil # don't intercept mails, send them
                                # as they are

  # ...
end
```

```ruby
# config/environments/staging.rb

# Based on production defaults
require Rails.root.join("config/environments/production")

Validations::Application.configure do
  config.action_mailer.default_url_options = { :protocol => 'https', :host => 'my-staging-app.com' }

  # Custom config option specific for this Application
  config.mail_interceptor = 'ServerMailInterceptor' # Intercept emails
end
```

```ruby
# config/environments/development.rb

Validations::Application.configure do

  # ... 100 lines of real development ENV configuration

  config.action_mailer.default_url_options = { :host => '0.0.0.0:3000' }

  # Custom config option specific for this Application
  config.mail_interceptor = 'DevelopmentMailInterceptor' # Intercept emails

  # ...
```

```ruby
# config/environments/test.rb

  config.action_mailer.delivery_method = :test  

  # ... 100 other lines of real test ENV configuration

  # mails are not intercepted by mail interceptor, but the option:                   
  #
  #    config.action_mailer.delivery_method = :test                                 
  #
  # configured above will stop them beeing delivered                                                     
  #
  config.mail_interceptor = nil    

  # ...
```


```ruby
# config/initializers/setup_mail.rb

# ...

if interceptor = Rails.configuration.mail_interceptor
  require "#{Rails.root.to_s}/lib/#{interceptor.underscore}"
  ActionMailer::Base.register_interceptor(interceptor.constantize)
end
```

```ruby
# lib/server_mail_interceptor.rb
class ServerMailInterceptor
  def self.delivering_email(message)
    # ...
    # same as staging_mail_interceptor.rb above
    # ...
  end
end
```

So this not exactly a rocket science. We tell what interceptor will
environment use inside environment configuration. Setting up own
option inside configuration block is provided by Rails 4 without any
additional monkey-patching or extending Rails. I  don't know about
lover versions of Rails as I have all my applications updated to latest
version. 

Production environment uses no interceptor and send mails directly.

Development environment uses own `DevelopmentMailInterceptor` as
originally described in Rails cast.

Staging environment file is basically loads all Production environment
settings and overriding environment based differences, including mail
interceptor option pointing to `ServerMailInterceptor``

This way when we add new environment (yes the `beta` environment)
everything would work just so nice avoiding headaches.

```ruby
# config/environments/beta.rb

# Based on production defaults
require Rails.root.join("config/environments/production")

Validations::Application.configure do
  config.action_mailer.default_url_options = { :protocol => 'https', :host => 'my-beta-app.com' }

  # Custom config option specific for this Application
  config.mail_interceptor = 'ServerMailInterceptor' # Intercept emails
end
```

**Note:** Not Many developers know that you can actually specify your own
environment configuration variable this way. The are actually cool for
other things as well,  e.q.: specify different CarrierWave gem storage
options for different environments:

```ruby
# config/environments/production.rb
MyApp::Application.configure do
  #...
  config.carrierwave_storage_type = :fog
  #...
end
```

```ruby
# config/environments/development.rb
MyApp::Application.configure do
  #...
  config.carrierwave_storage_type = :file
  #...
end
```

```ruby
# app/uploaders/branding_uploader.rb
class BrandingUploader < CarrierWave::Uploader::Base
  # ...
  storage(Rails.configuration.carrierwave_storage_type)  
  # ...
end
```

...this way when you introduce new environment you don't have to worry
about details whether the right storage option is selected.

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

Warning message is due to fact that `Mail` is not publicly accessible
constant. It's required by 
[ActionMailer::Base](https://github.com/rails/rails/blob/48ea0899074629203d84e2aea02593e893b5a2a4/actionmailer/lib/action_mailer/base.rb)
(Rails 4) as a part of [mail gem](https://github.com/mikel/mail) where
the interceptors are registered into class variable
`@@delivery_interceptors`.

It's cool to use this to make sure if we set interceptors correctly, it's
not cool to directly access it in production code.

Keywords: Rails 4.0.2, Ruby 2.1.1, own environment configuration, mail 
interceptor, stop mails in staging

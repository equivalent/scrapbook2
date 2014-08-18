```bash
bundle exec bin/delayed_job start # stop | status

```



```ruby
Delayed::Job.find(10).invoke_job # 10 is the job.id
```

```ruby

Delayed::Job.find(10).destroy
```



# disable delayed_job when running RSpec

you can do this in `spec_helper`

    # spec/spec_helper.rb
    Spork.prefork do
      ENV["RAILS_ENV"] ||= 'test'

      Delayed::Worker.delay_jobs = false

      RSpec.configure do |config|
        #....
      end
    end

or in initializer

    # config/initializers/delayed_jobs.rb
    Delayed::Worker.delay_jobs = !Rails.env.test?


or individually where you call it

    # app/model/notifications.rb
    def create_notifications
    end
    handle_asynchronously :create_notifications unless Rails.env.test?


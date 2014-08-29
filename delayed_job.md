
# delayed job init.d

```bash
#!/bin/sh
# upstart-job
#
# Symlink target for initscripts that have been converted to Upstart.

set -e
APP_ROOT=/home/deploy/apps/my_project/current
RAILS_ENV='production'

start_job() {
        echo "Starting delayed job"
        sudo -iu deploy bash -c "cd $APP_ROOT && RAILS_ENV=$RAILS_ENV bundle exec ./bin/delayed_job start"
}

stop_job() {
        echo "Stopping delayed job"
        sudo -iu deploy bash -c "cd $APP_ROOT && RAILS_ENV=$RAILS_ENV bundle exec ./bin/delayed_job stop"
}

COMMAND="$1"
shift

case $COMMAND in
status)
    ;;
start|stop|restart)
    $ECHO
    if [ "$COMMAND" = "stop" ]; then
        stop_job
    elif [ "$COMMAND" = "start" ]; then
        start_job
    elif  [ "$COMMAND" = "restart" ]; then
        stop_job
        sleep 1s
        start_job
        exit 0
    fi
    ;;
esac
```

```
    sudo chmod +x /etc/init.d/delayed_job_my_project
    sudo update-rc.d myscript defaults 98 02          #thos number are startup prority and end proces priority
```    

https://gist.github.com/stuzart/3169625
https://help.ubuntu.com/community/UbuntuBootupHowto

# old notes

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


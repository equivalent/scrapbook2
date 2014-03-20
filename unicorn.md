 unicorn server for Rails notes
 
 
run demonized with configuration file under rbenv 

```bash
# ~/apps/your_rails_app/
RAILS_ENV=staging rbenv exec unicorn -c config/unicorn.rb -D
```


### Unicorn config

```ruby
# config/unicorn.rb

working_directory "/home/deploy/apps/your_rails_app"
pid "/home/deploy/apps/your_rails_app/current_hack/tmp/pids/unicorn.pid"
stderr_path "/home/deploy/apps/your_rails_app/log/unicorn.log"
stdout_path "/home/deploy/apps/your_rails_app/log/unicorn.log"

listen '/tmp/unicorn.your_rails_app.sock' # this is the socket that will be picked up by NgineX
worker_processes 2
timeout 30
```

# unicorn start/stop

    # demon
    /etc/init.d/unicorn_myapp restart 
    
    # restart pid process
    kill -USR2 unicorn_master_pid;
    
    # reexecute unicorn master process, takes more time but reload most of the stuff
    kill -USR2 unicorn_master_pid; kill -QUIT unicorn_master_pid 
    
http://stackoverflow.com/questions/19896800/starting-or-restarting-unicorn-with-capistrano-3-x


super kill

    sudo kill `cat /home/deploy/apps/my_project/current/tmp/pids/unicorn.pid`
    
    ps aux | grep unicorn

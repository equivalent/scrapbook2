# unicorn server for Rails notes
 
@todo http://www.justinappears.com/blog/2-no-downtime-deploys-with-unicorn/ (no downtime deployment & rolling ) 
 
 
run demonized with configuration file under rbenv 

```bash
# ~/apps/your_rails_app/
RAILS_ENV=staging rbenv exec unicorn -c config/unicorn.rb -D
```


### Unicorn config

```ruby
# config/unicorn.rb

working_directory "/var/www/your_rails_app"
pid "/var/www/your_rails_app/current_hack/tmp/pids/unicorn.pid"
stderr_path "/var/www/your_rails_app/log/unicorn.log"
stdout_path "/var/www/your_rails_app/log/unicorn.log"

listen '/tmp/unicorn.your_rails_app.sock' # this is the socket that will be picked up by NgineX
worker_processes 2 # specifies the maximum number of seconds
                   # a worker can take to respond to a request before the
                   # master kills it and forks a new one
timeout 30
```

Note: I know lot of developers prefer to use `/home/deploy/apps/your_rails_app` directory but generally,
web apps are stored inside `/var/www` on Unix since the `/var` directory is designated for files that 
increase in size over time, which is the case with most web apps.
 
* https://github.com/blog/517-unicorn
* http://vladigleba.com/blog/2014/03/21/deploying-rails-apps-part-3-configuring-unicor/
* http://railscasts.com/episodes/293-nginx-unicorn


# unicorn init.d 

https://github.com/railscasts/335-deploying-to-a-vps/blob/master/blog-nginx/config/unicorn_init.sh

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

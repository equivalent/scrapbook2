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





## more descriptive example of unicorn init.d

```
# /etc/init.d/unicorn_myapp
#!/bin/sh
### BEGIN INIT INFO
# Provides:          unicorn
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Manage unicorn server
# Description:       Start, stop, restart unicorn server for a specific application.
### END INIT INFO

# Exit script if any statement returns a non-true return value
set -e

# Feel free to change any of the following variables for your app:
TIMEOUT=${TIMEOUT-60}
APP_ROOT=/home/deploy/apps/myapp/current
PID=/home/deploy/apps/myapp_deployment_setup/assets/unicorn/unicorn.myapp.pid

CMD="cd /home/deploy/apps/myapp/current; bundle exec unicorn -D -c /home/deploy/apps/myapp_deployment_setup/assets/unicorn/unicorn.conf.rb -E staging"
AS_USER=deploy

# Exit script if you try to use an uninitialised variable
set -u

OLD_PIN="$PID.oldbin"

sig () {
  test -s "$PID" && kill -$1 `cat $PID`
}

oldsig () {
  test -s $OLD_PIN && kill -$1 `cat $OLD_PIN`
}

run () {
  if [ "$(id -un)" = "$AS_USER" ]; then
    eval $1
  else
    su -c "$1" - $AS_USER
  fi
}

case "$1" in
start)
  sig 0 && echo >&2 "Already running" && exit 0
  run "$CMD"
  ;;
stop)
  sig QUIT && exit 0
  echo >&2 "Not running"
  ;;
force-stop)
  sig TERM && exit 0
  echo >&2 "Not running"
  ;;
restart|reload)
  sig USR2 && echo reloaded OK && exit 0
  echo >&2 "Couldn't reload, starting '$CMD' instead"
  run "$CMD"
  ;;
upgrade)
  if sig USR2 && sleep 2 && sig 0 && oldsig QUIT
  then
    n=$TIMEOUT
    while test -s $OLD_PIN && test $n -ge 0
    do
      printf '.' && sleep 1 && n=$(( $n - 1 ))
    done
    echo

    if test $n -lt 0 && test -s $OLD_PIN
    then
      echo >&2 "$OLD_PIN still exists after $TIMEOUT seconds"
      exit 1
    fi
    exit 0
  fi
  echo >&2 "Couldn't upgrade, starting '$CMD' instead"
  run "$CMD"
  ;;
reopen-logs)
  sig USR1
  ;;
*)
  echo >&2 "Usage: $0 <start|stop|restart|upgrade|force-stop|reopen-logs>"
  exit 1
  ;;
esac
```

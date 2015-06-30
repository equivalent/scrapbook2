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





## real life example of unicorn init.d

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
PID=/var/run/unicorn.myapp.pid

CMD="cd /home/deploy/apps/myapp/current; bundle exec unicorn -D -c /home/deploy/apps/myapp/config/unicorn.conf.rb -E staging"
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


## real life example of unicorn.conf

```
# /home/deploy/apps/myapp/config/unicorn.conf.rb

# Sample verbose configuration file for Unicorn (not Rack)
#
# This configuration file documents many features of Unicorn
# that may not be needed for some applications. See
# http://unicorn.bogomips.org/examples/unicorn.conf.minimal.rb
# for a much simpler configuration file.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
worker_processes 3

# Since Unicorn is never exposed to outside clients, it does not need to
# run on the standard HTTP port (80), there is no reason to start
Unicorn
# as root unless it's from system init scripts.
# If running the master process as root and the workers as an
unprivileged
# user, do this to switch euid/egid in the workers (also chowns logs):
# user "unprivileged_user", "unprivileged_group"

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory "/home/deploy/apps/myapp/current"

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen "/var/run/unicorn.myapp.sock", :backlog => 64
listen 8080, :tcp_nopush => true

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

# feel free to point this anywhere accessible on the filesystem
#pid "/path/to/app/shared/pids/unicorn.pid"
pid "/var/run/unicorn.myapp.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "/var/log/unicorn.stderr.log"
stdout_path "/var/log/unicorn.stdout.log"

# combine Ruby 2.0.0dev or REE with "preload_app true" for memory
savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

# Enable this flag to have unicorn test client connections by writing
the
# beginning of the HTTP headers before calling the application. This
# prevents calling the application for connections that have
disconnected
# while queued. This is only guaranteed to detect clients on the same
# host unicorn runs on, and unlikely to detect disconnects even on a
# fast LAN.
check_client_connection false

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  # The following is only recommended for memory/DB-constrained
  # installations. It is not needed if your system can house
  # twice as many worker_processes as you have configured.
  #
  # # This allows a new master process to incrementally
  # # phase out the old master process with SIGTTOU to avoid a
  # # thundering herd (especially in the "preload_app false" case)
  # # when doing a transparent upgrade. The last worker spawned
  # # will then kill off the old master process with a SIGQUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

  # Throttle the master from forking too quickly by sleeping. Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  sleep 1
end

after_fork do |server, worker|
  # per-process listener ports for debugging/admin/migrations
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis. TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
```

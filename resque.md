

Show what's going on:

```ruby
Resque.info
```

Show last 10 failed jobs:

```ruby
Resque::Failure.all(0,10)
```

Delete all failed jobs:

```ruby
Resque::Failure.clear
```

Delete all pending jobs

```ruby
Resque.queues.each { |q| Resque.redis.del "queue:#{q}" }
```

source: http://www.runshell.com/2014/07/handy-resque-commands.html


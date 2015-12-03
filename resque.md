
http://www.rubydoc.info/gems/resque/Resque/Failure


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


# retriggering failed resque jobs

```
# reque 800..last-job
 800.upto(Resque::Failure.count - 1) .each { |i| Resque::Failure.requeue(i) }

# Requeue all jobs in the failed queue
(Resque::Failure.count-1).downto(0).each { |i|
Resque::Failure.requeue(i) }

# Clear the entire failed queue
Resque::Failure.clear

# remove individual from failed
Resque::Failure.remove(1196)

```

https://ariejan.net/2010/08/23/resque-how-to-requeue-failed-jobs/

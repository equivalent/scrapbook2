```
Sidekiq.redis {|c| c.del('stat:processed') }

Sidekiq.redis {|c| c.del('stat:failed') }

Sidekiq::Queue.new("queue_name").size

Sidekiq::Queue.new("queue_name").clear


stats = Sidekiq::Stats.new
# Get the number of jobs that have been processed.
stats.processed # => 100

# Get the number of jobs that have failed.    
stats.failed # => 3

# Get the queues with name and number enqueued.
stats.queues # => { "default" => 1001, "email" => 50 }

#Gets the number of jobs enqueued in all queues (does NOT include
retries and scheduled jobs).
stats.enqueued # => 1051 
```

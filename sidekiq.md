https://github.com/mperham/sidekiq/wiki/API




```
# redis info
Sidekiq.redis { |c| p c.info }


Sidekiq.redis {|c| c.del('stat:processed') }

Sidekiq.redis {|c| c.del('stat:failed') }


Sidekiq::Queue.all  # array of objects
Sidekiq::Stats.new.queues   # { "default" => 1001, "email" => 50 }


# number of jobs in the queue
Sidekiq::Queue.new("queue_name").size  #doesn't work with redis 2.8 
                                       # works in redis 3.x

# number of jobs in the queue that works in in redis 2.8
# https://github.com/mperham/sidekiq/issues/2952
Sidekiq::Workers
  .new
  .map { |process_id, thread_id, work| work['queue']}
  .select { |queue_name| queue_name == "sqs_pull" }
  .size > 20



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

```bash
bundle exec bin/delayed_job start # stop | status

```



```ruby
Delayed::Job.find(10).invoke_job # 10 is the job.id
```

```ruby

Delayed::Job.find(10).destroy
```


Airbreake


```
File/gems/activerecord-4.2.5/lib/active_record/connection_adapters/abstract/connection_pool.rb:189
Hostname7f60f6563a86
Error typeActiveRecord::ConnectionTimeoutError
Error messageActiveRecord::ConnectionTimeoutErrorTimeoutError: could not
obtain a database connection within 5.000 seconds (waited 5.064 seconds)
Remote address52.18.167.29
User agent
ELB-HealthChecker     1.0
```

```
ActiveRecord::ConnectionTimeoutError: could not obtain a database
connection within 5.000 seconds (waited 5.064 seconds)
```

* https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
* https://devcenter.heroku.com/articles/concurrency-and-database-connections#threaded-servers

```ruby
ActiveRecord::Base.connection_pool.instance_eval { @size }
```

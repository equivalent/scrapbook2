# Ruby on Rails, Docker and AWS Elastic Beanstalk

In thin tutorial we are going to deploy [Ruby on
Rails](http://rubyonrails.org/) application


```ruby

ActiveRecord::Base.connection  # should not raise PG error

ActiveRecord::Base.connection.instance_variable_get(:@config)
# => {:adapter=>"postgresql", :host=>"172.17.0.3", :port=>5432, :database=>"archiveapp", :username=>"postgres", :password=>"mysecretlocalpassword", :pool=>5, :encoding=>"unicode", :timeout=>5000}
```

```
Rails.cache.fetch 'testredis' do
  'aaaa'
end

Rails.cache.fetch 'testredis' # => 'aaaa'

Rails.configuration.cache_store
# =>  [:redis_store, {:host=>"172.17.0.2", :port=>"6379", :db=>"0", :namespace=>"cache", :expires_in=>5400 seconds}]

```

[1]: https://hub.docker.com/_/postgres/ "Postgress docker image docs, ENV var examples"
[2]: https://docs.docker.com/compose/compose-file/ "Docker Compose documentation"


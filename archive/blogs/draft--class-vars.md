

The other day I was going through some code and seen a [Resque job](https://github.com/resque/resque)w
like this:

```
# app/jobs/foo_job.rb
class FooJob
  def self.perform(user_id:, ip:)
    @user = User.find(user_id: user_id)
    @ip = ip

    store_geo_data
  end

  private
    def store_geo_data
      address, country = fetch_geo_data(@ip)  # not important how we are
                                              # getting address
      @user.address = address
      @user.country = country
      @user.save
    end
end
```

As this code was not using Rails standard `ActiveJob::Base` but rather
hard-core call to Resque enqueue: `Resque.enqueue(FooJob, 123, '8.8.8.8')`


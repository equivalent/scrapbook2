

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
      @user.save!
    end
end
```

As this code was not using Rails standard `ActiveJob::Base` but rather
direct call to Resque enqueue: `Resque.enqueue(FooJob, 123, '8.8.8.8')`

### Ok, so what's wrong with this code:

As you can see the job has an class method `perform`. So behind the
sceen Resque is calling `FooJob.perform(user_id: 123, ip: '8.8.8.8')`

So far so good. The problem starts with setting instance variables
`@user = ...` and `@ip = ...`. You
see we are setting instance variables on class level. That means we are
doing something like this.

```ruby
class Foo
  def self.set_user
    @user = "User #{rand(0..10)}"
  end

  def self.set_ip
    @ip = "ip #{rand(0..10)}"
  end
end

Foo.instance_variable_get('@user')
# => nil
Foo.instance_variable_get('@ip')
# => nil

Foo.set_user

Foo.instance_variable_get('@user')
# => User 1460453360

# 20 minutes pass

Foo.instance_variable_get('@user')
# => User 1460453360


# Don't see any problem so far ? Ok imagine this scenario:

# in Thred safe worker enviroment  like Resque or Unicorn
# the l

Foo.set_user
Foo.set_ip

puts Foo.instance_variable_get('@user')
# => User 1
puts Foo.instance_variable_get('@ip')
# => ip 1


```




https://bearmetal.eu/theden/how-do-i-know-whether-my-rails-app-is-thread-safe-or-not/



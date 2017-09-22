# Danger of class state in Ruby or Rails applications

The other day I was going through some code and seen a [Resque job](https://github.com/resque/resque)
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
`@user = ...` and `@ip = ...`.
You see we are setting instance variables on class level. That means we are
doing something like this:

```ruby
class Foo
  def self.set_user
    @user = "User #{rand(0..9999)}"
  end

  def self.set_ip
    @ip = "ip #{rand(0..9999)}"
  end
end

Foo.instance_variable_get('@user')
# => nil
Foo.instance_variable_get('@ip')
# => nil

Foo.set_user

Foo.instance_variable_get('@user')
# => User 9

# 20 minutes pass

Foo.instance_variable_get('@user')
# => User 9  # random number didn't change
```
Don't see any problem so far ? OK look at this from this perspective:

In non-thread environment like Unicord or Resque, workers work in
(relatively) isolated worlds, so jobs are executed

> The isolation is relative to your configuration, there may be cases where you may share
> some stuff, e.g: `ActiveRecord::Base.connection`. So if you switch DB
> that may affect Worker.

...so they are executed like this:

```ruby
# worker 1
Foo.set_user
Foo.set_ip

puts Foo.instance_variable_get('@user')
# => User 1
puts Foo.instance_variable_get('@ip')
# => ip 1


# worker 2
Foo.set_user
Foo.set_ip

puts Foo.instance_variable_get('@user')
# => User 2
puts Foo.instance_variable_get('@ip')
# => ip 2
```

But in Threaded environments like Puma or Sidekiq jobs are sharing lot
of states ammongs which is class level state => class variables

> This apply for Ruby MRI (Cruby) threads.  With  Rubinius Threads you
> share  more levels (I'm not that familiar with Rubinius)

So if you lucky enough one job may endup before other ends and you won't
feel the pain:

```ruby
Foo.set_user # thread 1
Foo.set_ip   # thread 1

puts Foo.instance_variable_get('@user') # thread 1
# => User 1
puts Foo.instance_variable_get('@ip')   # thread 1
# => ip 1


Foo.set_user # thread 2
Foo.set_ip   # thread 2

puts Foo.instance_variable_get('@user') # thread 2
# => User 2
puts Foo.instance_variable_get('@ip')   # thread 2
# => ip 2

```

...but on a huge load jobs may be executed at the same time 



# in Thred safe worker enviroment  like Resque or Unicorn

https://bearmetal.eu/theden/how-do-i-know-whether-my-rails-app-is-thread-safe-or-not/



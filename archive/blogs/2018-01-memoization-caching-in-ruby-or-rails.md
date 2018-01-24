# Memoization, Caching and SQL query optimization in Ruby on Rails

> Recently we had a pair session with my colleague around how to speed up particular part of application.
> I was explaining several different techniques he could use in similar scenarios. I think it's worth 
> sharing with more developers.

```
Given application is looping through many fields
Why is Application making multiple SQL calls even if I memoize the object
```

or

```
Given application is looping through many items
How to prevent application doing expensive calculation on every item
```

### example Rails code

* Work has many comments
* work can be deleted only if there are no comments OR if admin user
* our view interface will display "delete work" only if can be deleted


> Note: we use Policy View Objects as described in http://www.eq8.eu/blogs/41-policy-objects-in-ruby-on-rails


```ruby
class WorksController < ApplicationController
	def index
		@works = Work.all
	end
end

<% @works.each do |work| %>
	 <%= link_to("Delete work", work, method: delete) if work.policy.able_to_delete?(current_user: current_user) %>
<% end %>

class Work < ActiveRecord::Base
	has_many :comments

	def policy
		 @policy ||= WorkPolicy.new
	end
end

class Comment
	belongs_to :work
end

class WorkPolicy
	attr_reader :work

	def initialize(work)
		@work = work
	end

	def able_to_delete?(current_user: nil)
		work_has_no_comments || (current_user && current_user.admin?)
	end

	private

	def work_has_no_comments
		work.comments.count < 1
	end
end
```

Now let say we have 100 Works in DB

This would result in multiple SQL calls:

    SELECT "works".* FROM "works"
    SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 1]
    SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 2]
    SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 3]
    SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 4]


### Memoization

First let's answer the 

> Why is Application making multiple SQL calls **even if I memoize the object**

Yes we are memoizing the Policy object with ` @policy ||= WorkPolicy.new` 

But we are not memoizing what that objects is calling. That mean we need to memoize the underlying object method call result. 

So if we did:

```ruby
@work = Work.last
@work.policy.able_to_delete?
#=> SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 100] # sql call 
@work.policy.able_to_delete?
#=> SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 100] # sql call 
@work.policy.able_to_delete?
#=> SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 100] # sql call 
```

... we would call multiple time the `comments.count`

But if we introduce another layer of memoization:

So let's change this:

```ruby
class WorkPolicy
	# ...

	def work_has_no_comments
		work.comments.count < 1
	end
end
```

To this:


```ruby
class WorkPolicy
	# ...

	def work_has_no_comments
		@work_has_no_comments ||= comments.count < 1
	end
end


@work = Work.last
@work.policy.able_to_delete?
#=> SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 100] # sql call 
@work.policy.able_to_delete?
@work.policy.able_to_delete?
```

As you can see the SQL call on count is made only the first time and then result is returned from memory of the object state.

### Caching 

But our case of "looping through multiple works" this would not work because we are initializing 100 Work objects with 100 WorkPolicy objects 

Best way to understand it is by running this code in your `irb`: 

```ruby
class Foo
	def x
		@x ||= calculate
	end

	private

	def calculate
			sleep 2 # slow query
			123
	end
end

class Bar
	def y
		@y ||= Foo.new
	end
end

p "10 times calling same memoized object\n"
bar = Bar.new
10.times do
	puts  bar.y.x
end

p "10 times initializing new object\n"

10.times do
	bar = Bar.new
	puts  bar.y.x
end
``


One way to deal with this is to use [Rails cache](edgeguides.rubyonrails.org/caching_with_rails.html)


```ruby
class WorkPolicy
	# ...

	def work_has_no_comments
		Rails.cache.fetch [WorkPolicy, 'work_has_no_comments', @work] do
			work.comments.count < 1
		end
	end
end

class Comment
	belongs_to :work, touch: true    # `touch: true` will update the Work#updated_at each time new commend is added/changed, so that we drop the cache 
end
```

> Now this is just stupid example. I know this should be probably cached this by introducing on `Work#comments_count` method and do the cache the count of comments in there. I just want to to demonstrate the options.


With caching like this in place, first time we run the `WorksController#index` we would get multiple SQL calls :

 
    SELECT "works".* FROM "works"
    SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 1]
    SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 2]
    SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 3]
    SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 4]
    # ...


...but second, third,  call would look like:


    SELECT "works".* FROM "works"
    # no count call

And if you add a new comment to the Work with id `3` :

    SELECT "works".* FROM "works"
    SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 3]


### Proper SQL

Now we are still not satisfied. We want that first run to be fast !
Problem is our way of how we are calling our associations (Comments). We are Lazy loading them:

```ruby
Work.limit(3).each {|w| w.comments }
# SELECT  "works".* FROM "works" WHERE  ORDER BY "works"."id" DESC LIMIT 10
# SELECT "comments".* FROM "comments" WHERE "comments"."work_id" = $1  ORDER BY comments.created_at ASC  [["work_id", 97]]
# SELECT "comments".* FROM "comments" WHERE "comments"."work_id" = $1  ORDER BY comments.created_at ASC  [["work_id", 98]]
# SELECT "comments".* FROM "comments" WHERE "comments"."work_id" = $1  ORDER BY comments.created_at ASC  [["work_id", 99]]
```

But if we eager load them:

```ruby
Work.limit(3).includes(:comments).map(&:comments)
# SELECT  "works".* FROM "works" WHERE "works"."deleted_at" IS NULL LIMIT 3
# SELECT "comments".* FROM "comments" WHERE "comments"."status" = 'approved' AND "comments"."work_id" IN (97, 98, 99)  ORDER BY comments.created_at ASC
```


> Read more about `includes`, `joins` in http://blog.scoutapp.com/articles/2017/01/24/activerecord-includes-vs-joins-vs-preload-vs-eager_load-when-and-where

So our code could be:

```ruby
class WorksController < ApplicationController
	def index
		@works = Work.all.includes(:comments)
	end
end

class WorkPolicy
	# ...

	def work_has_no_comments
		work.comments.size < 1        # we changed `count` to `size`
	end
end
```

Q: *Now wait a minute, isn't `comments.count` and `commets.size` the same ?*

Not really 
   

```ruby
10.times do
	work.comments.size
end  
# SELECT "comments".* FROM "comments" WHERE "comments"."work_id" = $1    ORDER BY comments.created_at ASC  [["work_id", 1]]
```

... loads all the comments to (something like) Array and does array calculation of the size (as if [].size)


```ruby
10.times do
	work.comments.count
end
# SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 1]]
# SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 1]]
# SELECT COUNT(*) FROM "comments" WHERE "comments"."work_id" = $1  [["work_id", 1]]
# ...
```

...executes  `SELECT COUNT` which is much faster than loading "all comments" to calculate the size, but then when you need to execute this 10 times you are explicitly making 10 calls


> Now I'm overexaturating with `work.comments.size` Rails is more clever in  determining if you just want just the `size`. In some cases it just executes `SELECT COUNT(*)` instead of "load all comments to array" and do [].size


It's simmilar like `.pluck` vs `.map`


```ruby
scope = Work.limit(10)
scope.pluck(:title)
# SELECT  "works"."title" FROM "works" LIMIT 10
# => ['foo', 'bar', ...]
scope.pluck(:title)
# SELECT  "works"."title" FROM "works" LIMIT 10
# => ['foo', 'bar', ...]

scope.map(&:title)
# SELECT  "works".* FROM "works" LIMIT 10
# => ['foo', 'bar', ...]
scope.map(&:title)
# => ['foo', 'bar', ...]
```


* `pluck` is faster as it only selects the `title` to array, but executes SQL call every time
* `map` will cause Rails to evaluate the `SELECT *` in order to populate `title` to array, but then you can work with loaded objects 



### Conclusion 

There is no silver bullet. It always depends on what you want to achive. 

One may argue that the "optimize SQL" solution works the best, but that's not true. You need to implement similar SQL optimization in every place where you are calling `work.policy.able_to_delete` which may be 10 or 100 places. `includes` may not be always good idea in terms of performance.

Cache can get supper chained in terms of what event should drop what part of the cache. If you don't do it properly your website may be displaying "out of date information" ! In case of policy objects that is super dangerous.

Memoization is not always flexible enough as you may  need to redesign large part of code base to achieve it and introduce too many layers of unnecessary abstraction 

> Not to mention that memoization is big No No in thread safe enviroments like Rubinius unless you sync your threads correctly. Don't worry you are fine with memoization (in 95% cases) if you use MRI, Rails & Puma are Thread safe but that's different kind of "thread safe". You really need to do something stuppid for that to be an issue. This article is way too long to go into that topic. Google it!

Really depends what your application (part of application) is aims for. My only recommendation is: Profile/benchmark your app ! Don't prematurely optimize. Use tools like New relic to discover what parts of your app are slow. 

Optimize gradually, don't build slow application and then In one sprint you will decide "Right, lets optimize" because you may find out that you made poor design choices and 50% of your App needs rewrite to be faster.

### Other solutions not mentioned

**Counter Cache**

* http://yerb.net/blog/2014/03/13/three-easy-steps-to-using-counter-caches-in-rails/
* http://guides.rubyonrails.org/association_basics.html (search for "counter cache")

**Database indexes**

May sound of topic but lot of performance issues happens because your app has no DB indexes (or too many premature indexes) 

* http://www.rakeroutes.com/blog/increase-rails-performance-with-database-indexes/

# Rails Associaton Relation (Arel) Magic

Given `User` `has_many :articles` in Ruby on Rails you can write something
like:

```ruby
User
  .first
  .articles
  .where(published: true)
  .where(tags: ['ruby'])
```

This is possible thanks to `ActiveRecord::Relation`. This use to be
separate project known as [Arel](https://github.com/rails/arel) but
since Rails 4 it was adopted by Rails core ([Rails Associations](http://guides.rubyonrails.org/association_basics.html)).

In this article we will have a look on some of my favorite tricks in
Arel / ActiveRecord::Relation.

## Basics


##### Conditions passed with question mark interpolation

```
User.where("users.first_name = ? and users.last_name = ?", 'Oliver', 'Sykes')
# SELECT "users".* FROM "users" WHERE (users.first_name = 'Oliver' and users.last_name = 'Sykes')
# => [] # User::ActiveRecord_Relation 

User.joins(:lessons).where("users.first_name = ? and lessons.title LIKE ?", 'Tomas', '%test%')
# SELECT "users".* FROM "users" INNER JOIN "lessons" ON "lessons"."user_id" = "users"."id"  WHERE (users.first_name = 'Tomas' and lessons.title LIKE '%test%')
# => [] # User::ActiveRecord_Relation 
```

Lot of developers prefer this type of syntax especially proponents of simple design or if the team consist
of developers for whom Ruby on Rails is not a primary concern of knowledge (E.G. SQL developers)

Now this is ok just remember NEVER EVER to do direct string interpolation with "#{}"!

```
## DON'T !!!
name = "I'm going to hack you;"
User.where("users.first_name = '#{name}'") # NEVER DO THIS !!!
# SELECT "users".* FROM "users" WHERE (users.first_name = 'Oliver' and users.last_name = 'Sykes')
```

...this would open your App to [SQL injection Attack](http://guides.rubyonrails.org/security.html#sql-injection).

The question mark syntax is being sanitized therefore it's safe

##### Arel with Ruby syntax

But we are Ruby developers, we like Ruby syntax so let's use it in our
example:

```
User.where(first_name: 'Oliver', last_name: 'Sykes')
# SELECT "users".* FROM "users" WHERE "users"."first_name" = 'Oliver' AND "users"."last_name" = 'Sykes'
# => [] # User::ActiveRecord_Relation 
```

> I will show you how to do the second example using plain Rails later in the article.

##### Arel Composition

Now biggest problem of previous two sections using single where scope approach is that developers are missing out biggest benefit
of ActiveRecord Relations and that is the composability: 

```
User
  .where(first_name: 'Oliver')
  .where(last_name: 'Sykes')

# SELECT "users".* FROM "users" WHERE "users"."first_name" = 'Oliver' AND "users"."last_name" = 'Sykes'
# => [] # User::ActiveRecord_Relation 

# ...or:

User
  .where("users.first_name = ?", 'Oliver')
  .where("users.last_name = ?", 'Sykes')
  .to_sql

# SELECT "users".* FROM "users" WHERE (users.first_name = 'Oliver') AND (users.last_name = 'Sykes')
# => [] # User::ActiveRecord_Relation
```

Join example:

```ruby
User
  .joins(:lessons)
  .where(first_name: 'Tomas')
  .where("lessons.title LIKE ?", '%test%')

# SELECT "users".* FROM "users" INNER JOIN "lessons" ON "lessons"."user_id" = "users"."id" WHERE "users"."first_name" = 'Tomas' AND (lessons.title LIKE '%test%')
# => [] # User::ActiveRecord_Relation
```

Reason why this is possible is because each part of the chain is
returning `User::ActiveRecord_Relation` therefore you can do:

```
olivers = User.where(first_name: 'Oliver')
# User::ActiveRecord_Relation
bmth_olivers = olivers.where("users.last_name = ?", 'Sykes')
# User::ActiveRecord_Relation
bmth_olivers.to_a
# =>  []
```

> If you are trying similar syntax in a console on your project you may be
> confused why I'm saying that return value
> of `User.where("users.first_name = ?", 'Oliver')`  is `User::ActiveRecord_Relation` but your
> console is showing `[]` and triggers a SQL query. Well both statemests are kindof true.
>
> You see Rails will not trigger SQL after every chain definition. Rather
> it "lazy evaluates" the last occurence. So in our case trying it  in
> console will trigger it after you hit ENTER.
>
> In reality Rails build a object that gets evaluated when it's needed
> e.g. when you tell that you want results in a Array `.to_a` or when you
> say `.first`


## Advanced

So lets take the composition of the ability of Rails ActiveRecord Relations to practice:

##### how to do OR

```ruby
# | type                        | owner_id | owner_type|
# | global                      | nil      | User      |
# | beloning to particular user | 123      | User      |

```

```ruby
# app/models/comment.rb

class Comment < ActiveRecord::Base

  scope :with_owner_ids_or_global, lambda{ |owner_class, *ids|
    with_ids = where(owner_id: ids.flatten).where_values.reduce(:and)
    with_glob = where(owner_id: nil).where_values.reduce(:and)

    where(owner_type: owner_class.model_name)
      .where(with_ids.or(with_glob)) # here is the OR part
  }
end

Comment.with_owner_ids_or_global(User, 1,2,3,4)
```

> sorry I cannot provide SQL output as the application no longer exist.


##### merging different model scopes


Let say User can be accesed via a [Public uid](https://github.com/equivalent/public_uid)

```ruby
class User < ActiveRecord::Base
  has_many :articles
  scope :for_public_uid, ->(uids) { where(id: uids) }
end


User.for_public_uid('abcd1234')
# SELECT "users".* FROM "users" WHERE "users"."public_uid" = $1  [["public_uid", 'abcd1234']]
=> #<ActiveRecord::Relation []>

User.for_public_uid(['abcd1234', 'xyzff235'])
# SELECT "users".* FROM "users" WHERE "users"."public_uid" IN ('abcd1234', 'xyzff235')
=> #<ActiveRecord::Relation []>

```

Now we want to implement scope on associated user articles for that user ID. We could explicitly replicate the
logic but much easier and cleaner way is to  `merge` the associated model scope:


```ruby
class Article < ActiveRecord::Base
  belongs_to :user
  scope :for_user_public_uid, ->(user_public_uids) { joins(:criterium_decision).merge(CriteriumDecision.for_public_uid(user_public_uids)) }+
end


Article.for_user_public_uid('1234')

# SELECT "articles".* FROM "articles"
#  INNER JOIN "users" ON "users"."id" = "article"."user_id"
#  WHERE "users"."public_uid" = '1234'

Article.for_user_public_uid(['xyz12345', 'eeee4444'])

# SELECT  "articles".* FROM "articles"
#  INNER  JOIN "users" ON "users"."id" = "articles"."user_id"
#  WHERE  "users"."pubic_uid" IN ('xyz12345', 'eeee4444')
# => #<ActiveRecord::Relation []>
```

##### composing scope under a conditioning

Often developers are in a situation where their #index controller action
should return all records but only limited part of that scope when
certain param is sent (pagination, limit endpoint for M:M API, ...)

Way too often I see developers replicate the same code whene really they
can took adventage of the fact that `ActiveRecord::Relation` is
composable like a lego blocks (as we demonstrated in the beginer section)

We will use the `Article` and `User` relation from previous example:

```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController

  # /articles or /articles?user_ids[]=x1y2&user_ids[]=p4b3
  def index
    articles = Articles.all

    # `articles` holds lazy `ActiveRecord::Relation` therefore the SQL was not yet triggerd

    if limited_user_ids = params[:user_ids]  # if we are limiting scope to only certain articles
       articles = artices.for_user_public_uid(limited_article_ids)
    end

    # again, `articles` is still lazy `ActiveRecord::Relation`, we can add more complexicity to it

    articles = articles.order(:created_at)

    render json: articles.as_json # now the SQL is executed !
  end
```

> **Note**: `.all` returns an `ActiveRecord::Relation` only for Rails 4
> and up. Rails 3 will retun array. In Rails 3 you need to use
> `Article.scoped`


```sql
SELECT "articles".* FROM "articles" ORDER BY "articles"."created_at" ASC
```

```sql
SELECT "articles".* FROM "articles" INNER JOIN "users" ON "users"."id" = "articles"."user_id"
   WHERE "users"."url_slug" IN ('x1y2', 'p4b3')  ORDER BY "articles"."created_at" ASC
```




## Debugging 

##### Show what SQL will get executed

on any `ActiveRecord::Relation` object you can call `to_sql` to see what
SQL command will be executed

```
puts User.all.to_sql
# SELECT "users".* FROM "users"
# => nil

puts User.where(id: nil)
# SELECT "users".* FROM "users" WHERE "users"."id" IS NULL
# => nil
```


============================================================================================================================




# Sources

* more on [simple design](https://www.youtube.com/watch?v=rI8tNMsozo0)

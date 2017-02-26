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

> I've collected  these tricks over years in my
> [scrapbook](https://github.com/equivalent/scrapbook2/blob/master/rails_active_record.md),
> so therefore for some examples I wont be able to provide SQL output

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
```

...this would open your App to [SQL injection Attack](http://guides.rubyonrails.org/security.html#sql-injection).

> The question mark syntax is being sanitized therefore it's safe.
> Direct string interpolation is not.

##### Arel with Ruby syntax

But we are Ruby developers, we like Ruby syntax so let's use it in our
example:

```
User.where(first_name: 'Oliver', last_name: 'Sykes')
# SELECT "users".* FROM "users" WHERE "users"."first_name" = 'Oliver' AND "users"."last_name" = 'Sykes'
# => [] # User::ActiveRecord_Relation 
```

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


##### Merge different model scopes


Let say User can be accesed via a [public uid](https://github.com/equivalent/public_uid)

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
  scope :for_user_public_uid, ->(user_public_uids) { joins(:criterium_decision).merge(CriteriumDecision.for_public_uid(user_public_uids)) }
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

Merge can be implemented on any scope returnig "ActiveRecord::Relation":

```ruby
class DocumentVersion
  scope :order_by_latest, ->{ order("document_versions.id DESC") } 
end

class Document
  scope :order_by_latest, ->{ joins(:document_versions).merge(DocumentVersion.order_by_latest) }
end

Document.order_by_latest
```

##### composing scope under a conditioning

Often developers are in a situation where their `#index` controller action
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

##### IS NOT NULL

```ruby
Foo.where.not(id: nil)
```

If you need to do a join:

```
# ok
Foo.includes(:bars).where('bars.id IS NOT NULL')

# good
Foo.includes(:bars).where(Bar.arel_table[:id].not_eq(nil))
```

##### multiple query ActiveRecord::Scopes

Sometimes you need your Rails scope to perform muliple SQL calls.

```ruby
class User < ActiveRecord::Base
  # ...

  scope :friend_comments, -> {
    friend_ids = User.where(friend: true).pluck(:id).uniq
    ex_girlfriend_ids = User.where(ex: true).pluck(:id).uniq
    Comment.where(user_id: friend_ids).where.not(ex_girlfriend_ids)
  }
end
```

Now this is stupid example, but you get the point. We do 3 SQL calls for
one Rails scope. Arguably this could be 3 scopes but there are
situations where you need this to be in single one.

In expert section we will deponstrate how to do this even better with
Query objects :)

##### Model caching Query ids


Simlar to  previous example

```ruby
class User < ActiveRecord::Base
  # ...

  scope :friend_comments, -> {
    friend_ids = User.where(friend: true).pluck(:id).uniq
    ex_girlfriend_ids = User.where(ex: true).pluck(:id).uniq
    Comment.where(user_id: friend_ids).where.not(ex_girlfriend_ids)
  }
end
```



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


##### Multiple OR with bracket separation

...basically just more complex SQL query with OR statement where brackets will
separate the desired domain context:

```ruby
# app/model/candy.rb
class Candy < ActiveRecord::Base
  has_many :candy_ownerships
  has_many :clients, through: :candy_ownerships, source: :owner, source_type: 'Client'
  has_many :users,   through: :candy_ownerships, source: :owner, source_type: 'User'

  # ....
  scope :for_user_or_global, ->(user) do
    worldwide_candies  = where(type: 'WorldwideCandies').where_values.reduce(:and)
    client_candies     = where(type: 'ClientCandies', candy_ownerships: { owner_id: user.client.id, owner_type: 'Client'}).where_values.reduce(:and)
    user_candies       = where(type: 'UserCandies',   candy_ownerships: { owner_id: user.id,        owner_type: 'User'  }).where_values.reduce(:and)

    joins(:candy_ownerships).where( worldwide_candies.or( arel_table.grouping(client_candies) ).or( arel_table.grouping(user_candies) ) )
  end

  # ....
end

Candy.for_user_or_global(User.last)
#=> SELECT `candies`.* FROM `candies` INNER JOIN `candy_ownerships` ON `candy_ownerships`.`candy_id` = `candies`.`id` WHERE (`candies`.`deleted_at` IS NULL) AND (((`candies`.`type` = 'WorldwideCandies' OR (`candies`.`type` = 'ClientCandies' AND `candy_ownerships`.`owner_id` = 19 AND `candy_ownerships`.`owner_type` = 'Client')) OR (`candies`.`type` = 'UserCandies' AND `candy_ownerships`.`owner_id` = 121 AND `candy_ownerships`.`owner_type` = 'User')))
```




##### Lower than

```irb
Event.arel_table[:start_at].lt(Time.now).to_sql
=> "`events`.`start_at` < '2013-03-05 10:38:22'"
```

...and yes this works with is `gt` too.

##### Arel give me records that have empty / no associations


So this is trying to say: "Give me all users which has no permissions"

```
User
  .joins('FULL OUTER JOIN permissions on permissions.user_id = users.id')
  .where(permissions: {user_id:nil})
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



## Dump of more examples:

##### complex scope example

```ruby
class Document
  scope :with_latest_super_owner, lambda{ |o|
    raise "must be client or user instance" unless [User, Client].include?(o.class)
    joins(:document_versions, document_creator: :document_creator_ownerships).
    where(document_creator_ownerships: {owner_type: o.class.model_name, owner_id: o.id}).
    where(document_versions: {latest: true}).group('documents.id')
  }
end
```

```ruby
scope :visible, -> { where("hidden != ?", true) }
scope :published, -> { where("published_at <= ?", Time.zone.now) }
scope :recent, -> { visible.published.order("published_at desc") }
scope :desc_order, ->{ order(created_at: :desc) }

#bad
has_one :custom_form, -> { order('created_at DESC') }, class_name: CustomForm
# SELECT ORDER BY created_at DESC LIMIT 

#good
has_one :custom_form, -> { order(created_at: :desc) }, class_name: CustomForm
# SELECT .... ORDER BY "custom_forms"."created_at" DESC LIMIT 1
```


## Sources

* more on "Lazy" evaluation http://www.eq8.eu/blogs/28-ruby-enumerable-enumerator-lazy-and-domain-specific-collection-objects
* more on [simple design](https://www.youtube.com/watch?v=rI8tNMsozo0)

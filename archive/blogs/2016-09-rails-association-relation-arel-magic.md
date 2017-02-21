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
...

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


##### using different model scopes

```ruby
class CriteriumDecision < ActiveRecord::Base
  has_many :articles
  scope :for_url_slugs, ->(url_slugs) { where(url_slug: url_slugs) }
end
```


```ruby
class DecisionDiscussionItem < ActiveRecord::Base
  scope :for_criterium_decision_url_slugs, ->(url_slugs) do
    joins(:criterium_decision).merge(CriteriumDecision.for_url_slugs(url_slugs))
  end
end
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



```ruby
        ddis = AssessmentFile
          .find_param(params[:assessment_file_id])
          .decision_discussion_items

        if criterium_decision_url_slugs =
params[:criterium_decision_ids]
          ddis =
ddis.for_criterium_decision_url_slugs(criterium_decision_url_slugs)
        end

        ddis = ddis.order(:created_at)
```ruby




```sql
SELECT "decision_discussion_items".* FROM "decision_discussion_items" WHERE "decision_discussion_items"."assessment_file_id" = 1  ORDER BY "decision_discussion_items"."created_at" ASC
```

```sql
.SELECT "decision_discussion_items".* FROM "decision_discussion_items" INNER JOIN "criterium_decisions" ON "criterium_decisions"."id" = "decision_discussion_items"."criterium_decision_id" WHERE "decision_discussion_items"."assessment_file_id" = 3 AND "criterium_decisions"."url_slug" IN ('ed16de83', 'non-existing')  ORDER BY "decision_discussion_items"."created_at" ASC
```


# Sources

* more on [simple design](https://www.youtube.com/watch?v=rI8tNMsozo0)

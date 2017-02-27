# Rails ActiveRecord Relation (Arel), composition and Query Objects

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
since Rails 3 it was adopted by Rails core ([Rails Associations](http://guides.rubyonrails.org/association_basics.html)).

In this article we will have a look on some of my favorite tricks in
Arel / `ActiveRecord::Relation`.

> I've collected  these tricks over years in my
> [scrapbook](https://github.com/equivalent/scrapbook2/blob/master/rails_active_record.md),
> so therefore for some examples I wont be able to provide SQL output
> Each time I stumble upon new example I'll add it here (suggestions
> welcome, you can PR this article).

## Beginner

> This artile may be too long, therefore
> Advanced Rails developers may want to skip the Beginer part.

#### Conditions passed with question mark interpolation

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

#### Arel with Ruby syntax

But we are Ruby developers, we like Ruby syntax so let's use it in our
example:

```
User.where(first_name: 'Oliver', last_name: 'Sykes')
# SELECT "users".* FROM "users" WHERE "users"."first_name" = 'Oliver' AND "users"."last_name" = 'Sykes'
# => [] # User::ActiveRecord_Relation 
```

#### ActiveRecord::Relation Composition

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

* more on "Lazy" evaluation http://www.eq8.eu/blogs/28-ruby-enumerable-enumerator-lazy-and-domain-specific-collection-objects
* more on [simple design](https://www.youtube.com/watch?v=rI8tNMsozo0)


## Advanced

So lets take composition ability of Rails ActiveRecord Relations to practice:


#### Merge different model scopes


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

#### Composing scope under a conditioning

Often developers are in a situation where their `#index` controller action
should return all records but only limited part of that scope when
certain param is sent (pagination, limit endpoint for M:M API, ...)

Way too often I see developers replicate the same code when really they
can took advantage of the fact that `ActiveRecord::Relation` is
composable like a lego blocks (as we demonstrated in the beginner section)

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
# /articles
SELECT "articles".* FROM "articles" ORDER BY "articles"."created_at" ASC
```

```sql
# /articles?user_ids[]=x1y2&user_ids[]=p4b3
SELECT "articles".* FROM "articles" INNER JOIN "users" ON "users"."id" = "articles"."user_id"
   WHERE "users"."url_slug" IN ('x1y2', 'p4b3')  ORDER BY "articles"."created_at" ASC
```

#### IS NOT NULL

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

#### Multiple SQL query in single ActiveRecord scope

Sometimes you need your Rails scope to perform multiple SQL calls.

```ruby
class User < ActiveRecord::Base
  # ...

  scope :premium_comments, -> {
    banned_user_ids = User.where(banned: true).pluck(:id).uniq
    premium_user_ids = User.where(ex: true).pluck(:id).uniq
    Comment.where(user_id: premium_user_ids).where.not(banned_user_ids)
  }
end
```

Now this is stupid example, but you get the point. We do 3 SQL calls for
one Rails model scope. Arguably better practice would be to write 3 scopes but there are
situations where you need this to be in single one (e.g. you are just
performance refactoring scopes and don't want to introduce extra scopes)

> ok maybe the same solution could be achieved with `.joins` or `.includes` but let say that would kill
> your performance on 1M records. Think about this as a [Dependancy Inversion principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle)
>  that you can perform on a SQL query.

In expert section we will demonstrate how to do this even better with
Query objects.

#### Model caching Query ids


Similar to previous example: let say that `banned_user_ids` and
`premium_user_ids` are coming from expensive query, Redis DB or some
microservice.

We can cache these IDs:

```ruby
class User < ActiveRecord::Base
  # ...

  def self.banned_user_ids
    Rails.cache.fetch 'app_banned_user_ids', expires_in: 24.hours do
      # expensive SQL query ...or other type of DB
    end
  end

  def self.premium_user_ids
    Rails.cache.fetch 'app_premium_user_ids', expires_in: 5.minutes do
      # microservice call
    end
  end

  scope :premium_comments, -> {
    Comment.where(user_id: premium_user_ids).where.not(banned_user_ids)
  }
end
```

Now I'm just demonstrating the potential of caching here I don't have
time to explain how to do caching properly. In brief: to use
`expires_in` for cache is not the best approach. Rather drop the cache
on some relevant event, like some Redis event flag, Rails [touch association](http://apidock.com/rails/ActiveRecord/Persistence/touch)
(or if you are really lazy at least: `Rails.cache.fetch "app_#{User.maximum(:updated_at)}banned_user_ids"`)

Just remember to cache simple data (array of strings or integers) not marshaled objects!

More on caching:

* http://guides.rubyonrails.org/caching_with_rails.html
* https://www.youtube.com/watch?v=q8ausBZTrxU

#### How to do OR

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


#### Multiple OR with bracket separation

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

#### Lower than

```irb
Event.arel_table[:start_at].lt(Time.now).to_sql
# => "`events`.`start_at` < '2013-03-05 10:38:22'"

Event.where(Event.arel_table[:start_at].lt(Time.now))
```

...and yes this works with is `gt` too.

#### Order by DESC

```ruby
Comment.order(Comment.arel_table['created_at'].desc)
```

#### Arel - give me records that have empty / no associations

```
User
  .joins('FULL OUTER JOIN permissions on permissions.user_id = users.id')
  .where(permissions: { user_id: nil } )
```

So this is trying to say: "Give me all users which has no permissions"


## Expert

#### Query objects

If you ever worked on a project where first 200 lines of `User` model
are just association definition and scope definition you probably
understand the pain of scope maintenance. One way to deal with this is
to extract out the scope logic to separate composable  objects.

Now the thing is that every developer has his own way how to define
Query objects and I've never seen a "bad" approach example (as long as
you leave the query object result to return `ActiveRecord::Relation`. It's purely
matter of taste. Therefore I'll provide you example how I implement them
and feel free to come up with a way that will benefit your team.


Now I'm going to create an example from top of my head so it may not be
100% without errors. I just want to demonstrate the potential:

```ruby
class CommentsController < ApplicationController
  # ...
  def index
    # ...

    @organization = Organization.find[:ordanization_id]
    @comments = @organization.comments
    @comments = BannedSourcesQuery.new(@comments).call
    @comments = ActiveCommentsQuery.new(@comments).call
    @comments = CommentPolicy::Scope.new(@comments, current_user).viewable_comments
    @comments = @comments.order(Comment.arel_table['created_at'].desc)
    # ...
  end

end
```

```ruby
class BannedSourcesQuery
  attr_reader :scope

  def initialize(scope)
    @scope = scope
  end

  def call
    scope
      .where.not(user_id: banned_user_ids)
      .where.not(flagged: true)
  end

  private
    def banned_user_ids
       # this can be:
       User.where(banned: true).pluck(:id)

       # or:
       Rails.cache.fetch 'app_banned_user_ids' do
          # ... API call or expensive SQL
       end
    end
end

class ActiveCommentsQuery
  attr_reader :scope

  def initialize(scope)
    @scope = scope
  end

  def call
    scope
      .where(Comment.arel_table["active"].eq true)
      .where(Comment.arel_table[:publish_day].gt(Time.now))
  end
end

class CommentPolicy::Scope
  attr_reader :scope, current_user

  def initialize(scope, current_user)
    @scope = scope = scope
    @current_user = current_user
  end

  def viewable_comments
    scope
      .where(organization_id: current_user.organization_id)
  end

  # ...
end
```


So in this example we are already showing 3 types of Query objects:

`BannedSourcesQuery` is reusable query object that may be called on any
type of scope (not only for Comments).
As long as the relevant model has `flagged` and `user_id` fields.
So it's sort of [duck
type](https://en.wikipedia.org/wiki/Duck_typing) composble query object
that can be reused trough out the application to remove "blacklist"
users from any scope e.g.: `BannedSourcesQuery.new(Document.all).call`

`ActiveCommentsQuery` is non reusable query object specific to a
particular model (in this case Comment). The beauty is that you are
ensuring `comments.` fields are called. This has nice side effect that
you can do something like this:

```ruby
q = Document.joins(:comments)
q = ActiveCommentsQuery.new(q).call

documents_with_active_comments = q.order('documents.id')
```

> Now the reusability of query objects if optional. I just want to
> demonstrate that you can make your code design more flexible with query
> objects not more complex or more difficult to understand as many are afraid.

Last Query object is so called policy scope query object.

I don't have time to explain what are policy objects (and I'm already preparing separate article on that topic)
but think about policy objects as objects where you pass
a record object and current session user and you just ask if given user has permission to do
something with the object (e.g. `CommentPolicy.new(Comment.last, current_user).can_view?`)
if you want to learn more you can check [pundit](https://github.com/elabs/pundit) gem.

Similar way works the "policy scope query objects". You pass scope and
`current_user` and expect the object to return you limited scope that
user can perform given action (`.viewable`, `.editable`)

Last line in our controller is just implementing order DESC by
`comments.created_at`. This is to demonstrate that it's ok to mix model
scopes and query objects.

Now again, query objects come in many flavors. Other Rails developers
may agree or disagree with the use I've presented. It's really up to you
and your team to figure out what approach will work for you. Just be
careful not to repeat same query object in multiple files. Lot of time having
just single `.call` method on a query object is required to enforce single responsibility but lot
of time it makes more sense to have multiple public methods on query
object in order to avoid replicating code, or to avoid including intermediary
Ruby module / Rails concern. My advice is be pragmatic about it. Also don't prematurely
extract Rails scopes to query objects. The day will come when it feels
right.

> I've avoided Query Objects that do `.joins` or `.includes` as they are
> harder to explain, but that doesn't mean they don't exist. You can do
> same things you would normally do with scopes.

more sources:

* http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
  (`4. Extract Query Objects` & `6. Extract Policy` section)


## Debugging

#### Show what SQL will get executed

on any `ActiveRecord::Relation` object you can call `#to_sql` or
`#explain` to see what
SQL command will be executed

```ruby
puts User.all.to_sql
# SELECT "users".* FROM "users"
# => nil

puts User.where(id: nil).to_sql
# SELECT "users".* FROM "users" WHERE "users"."id" IS NULL
# => nil


User.where(id: 1).explain
#   User Load (1.6ms)  SELECT "users".* FROM "users" WHERE "users"."id" =
# $1  [["id", 1]]
#  => EXPLAIN for: SELECT "users".* FROM "users" WHERE "users"."id" = $1
# [["id", 1]]
#                                 QUERY PLAN
# --------------------------------------------------------------------------
#  Index Scan using users_pkey on users  (cost=0.29..8.31 rows=1
# width=648)
#    Index Cond: (id = 1)
# (2 rows)
```

## Testing

In my opinion biggest problem is "how would you test this" ?

Many would say that Rails is well tested all we need to test if correct
scopes are called in order and they will write test like this:

```ruby
RSpec.describe CommentsController do
  # ...
  it do
    # ...
    expect(Comment)
      .to receive_message_chain(:pending, :where, :where, :order)
      .and_return comments_double
    # ...
  end
end
```

Honestly if you do this it's just matter of "when" that you'll receive phone call at 3am from your boss to fix a critical security bug.
Think about this use of `receive_message_chain` just as a "interface
test" not really proving anything just ensuring if stuff gets called. 

It's way to easy to make a mistake in SQL with Arel (especially if you use `.includes` or `.joins`)
Even if you are the best SQL programer in your country you still cannot
prevent that a junior developer will edit the `where` clause incorrectly
and your test will have no idea about this.

So some will test individual "query objects" and scopes with real
records. And just ensure those scopes/objects get's called with correct
arguments. Well honestly you are doing the similar mistake just slowing
down your test suite.

Therefore lot of developers will argue "Do a full integration test". 

Well if your controller #index action has 50 different scenarios and for
each controller action test you need to create 10 to 20 records just to prove if they pass,
even with medium size project your test suite will run 20min - 60min.
Plus you need to test if correct html/json is rendered and
wheather you have proper status, authorization/authentication ...

So how to test them ?

Look, the thing is that neither Controller neither Query object/ model scope is place
for this kind of responsibility.

We are missing one level of abstraction. I like to call it "Query
inteface" but in reality they are just a class method / separate module
method that calls the composed query.

```ruby
# From this:
#    controller1 >  scope where Query.object scope scope order
#    controller2 >  scope Query.object Query.object  scope order
#    controller3 >  scope where where where order
#
# To this:
#    controller1 > QueryInterface 1  > scope where Query.object scope scope order
#    controller2 > QueryInterface 2  > scope Query.object Query.object  scope order
#    controller3 > QueryInterface 3  > scope where where where order
```

To put this in code:

```ruby
module AdminQueryInterface
  def self.comments_including_for_approval(organization:)
    comments = Comment.where(organization_id: organization.id)
    comments = SomeQueryObject.new(comments).call
    comments = comments.some_scope.where(approved: true)
    commets
  end

  # ....
  # many more Query Interfaces of similar context
end


class CommetsController  < ApplicationController
  def self.whitelisted_comments(current_user:)
    comments = current_user.comments
    comments = SomeQueryObject.new(comments).call
    comments = comments.some_scope.where(approved: true)
    comments = comments.order("commets.id DESC")
    comments
  end

  # ...
  def index
    if admin?
      organization = Organization.find(param[:org_id]
      comments = AdminQueryInterface
         .comments_including_for_approval(organization: organization)
    else
      comments = CommetsController.whitelisted_comments(current_user: current_user)
    end

    render json: comments.as_json
  end
end
```

Then all I need to do is to test the query interfaces with data from test DB and just
ensure that the correct methods get called in the controller:

```ruby

RSpec.describe 'CommetsController' do
  describe 'GET #index' do
    # ...
    context "admin" do
      # ...
      it do
        xyz_org = Organization.last

        expect(AdminQueryInterface)
          .to receive(:comments_including_for_approval)
          .with(organization: xyz_org)
          .and_return([instance_double(Comment)])
        # ...
        get :index
        expect(response.status).to eq 200
        expect(JSON.parse(body)).to match({.....})
      end
    end

    context "user" do
      # ...
      it do
        expect(CommetsController)
          .to receive(:whitelisted_comments)
          .with(current_user: current_user)
          .and_return([instance_double(Comment)])
        # ...
        get :index
        expect(response.status).to eq 200
        expect(JSON.parse(body)).to match({.....})
      end
    end
  end

  describe '.whitelisted_comments', slow_test: true do
    # ...
    let(:user) { create :user, organization: my_org)
    let!(comment1) { create :comment, :naughty, organization: my_org }
    let!(comment2) { create :comment, :nice, organization: my_org }
    let!(comment3) { create :comment, :nice, organization: different_org }
    # ...

    let(:result) { CommentsController.whitelisted_comments(current_user: user) }

    it do
      expect(result).to eq([comment2])
    end
  end
end

RSpec.describe AdminQueryInterface do
  describe '.comments_including_for_approval', slow_test: true do
    # ...
    let!(comment1) { create :comment, :naughty, organization: my_org }
    let!(comment2) { create :comment, :nice, organization: my_org }
    let!(comment3) { create :comment, :nice, organization: different_org }
    # ...

    let(:result) { CommentsController.whitelisted_comments(organization: my_org) }

    it do
      expect(result).to eq([comment2, comment1])
    end
  end
end
```



> Again, this test is just for demonstration there is still lot that can be
> imploved around this test such as extracting the common `let!` into
> [shared context](https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-context)
> so that we are sure the test stays relevant for both cases if one test
> gets updated. I'm preparing article on this topic too and will publish
> it till summer.


So this way we can test multiple scenarios with our data and if you are
still concern about the speed of test, we are implementing the [RSpec tag](https://www.relishapp.com/rspec/rspec-core/v/2-4/docs/command-line/tag-option)
`slow_test` so therefore we can configure our CI to run slow test at the
end:

```bash
bundle exec rspec spec --tag ~slow_test  #skip slow tests
bundle exec rspec spec --tag slow_test   #run just slow tests
```

The point is that our controller test (that should test just responses,
correct objects gets called, and maybe [JSON API test](http://www.eq8.eu/blogs/30-native-rspec-json-api-testing))
will still run relatively fast.

> If you are still nervous you've missed something you can still implement one or two "smoke"
> tests (like with Selenium interface test or [RSpec request test](https://www.relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec))
> but the point is you wont have to do it for every possibility.

Now you may be against this and say that implementing such a Query
Interface  for every simple controller is a waste of effort if you have just single scope or
single Query object in your controller . Well yes it
is, sort of.

Usually first I write test for every query object  or Rails model `scope` I write (
similar `let!(...) {..}; let!(...) {..}; expect(result).to  ...` way),
but I do it so I have some TDD
flavor to my coding. But in reality I see it just as a temporary test
that I'm ready to throw away once I implement this Query interface test
if stuff gets bigger. Sure sometimes the project is really small and I keep this kind of
query/scope test in place for couple of weeks/months. But when the day
comes  I extract out valuable parts of the tests to
query interface test and throw the original test away.

The point is: Don't rely on Query object / Rails model scope tests as on
Lego blocks that will "just work" once you join them. Once you start
combining them there is a lot that could go wrong in complex solution.

**NOTE:**

Bottom point of Query Interface is that you don't call any other
relation after it!

So no:

```ruby
# DONT
class MyController < ApplicationController
  # ...
  def index
    # ...
    c = AdminQueryInterface
      .comments_including_for_approval(organization: organization)
      .limit(10) # DONT!
    # ...
  end
  # ...
end
```

If you need "similar" example with just one altertaion then just define new Query Interface method and
use that one and test it separatly:

```ruby
module AdminQueryInterface 
  # ...
  def comments_including_for_approval_paginated(organization:, limit: )
    comments_including_for_approval(organization: organization).limit(limit)
  end
end
```

You need to be sure your test represent the end product that is used to
produce the SQL call.

## Conclusion 

Sorry for the long post. But I hope you understand that this needed some
level of explanation. I will keep this blog post updated each time I come up with a new trick.

The thing is Arel is really dynamic tool and allows developers to do the
same thing many many ways. But once your project becomes corporate level
size you will struggle to survive unless you establish common process
for your team. I hope this article will inspire you with some practices
but don't stop here and try to come up with those that fits you and your
team.



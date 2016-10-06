# Rails Active Record Scrapbook

# rails concerns

```
require 'active_support/concern'

module Foo
  extend ActiveSupport::Concern
  included do
    def self.method_injected_by_foo
      ...
    end
  end
end

module Bar
  extend ActiveSupport::Concern
  include Foo

  included do
    self.method_injected_by_foo
  end
end

class Host
  include Bar # It works, now Bar takes care of its dependencies
end
```

http://api.rubyonrails.org/classes/ActiveSupport/Concern.html

# get the Active record (rails) db configuration

```
ActiveRecord::Base.connection.instance_variable_get(:@config)
```

# order via Arel table


    class User < ActiveRecord::Base
      has_many :status_changes

      def latest_status_change
        status_changes
         .order(StatusChange.arel_table['created_at'].desc) #
         .first
      end
    end
 
    class StatusChange < ActiverRecord::Base
      belongs_to :user
    end

resulting in:

    SELECT "status_changes".* FROM "status_changes" WHERE "status_changes"."user_id" = 1 ORDER BY "status_changes"."created_at" DESC

Benefits: 

* you are strictly bound to Modelclass name => renaming table in model will not break the sql code (of if it will, it will explicitly break the syntax on Ruby level, not DB level)
* you still have the benefit of explicitly saying what table.column the order should be 

http://apidock.com/rails/ActiveRecord/QueryMethods/order


# none

```
# two are the same thing
tld.validation_types.templates.select { |vt| vt.fields.count == 0  }.empty?
tld.validation_types.none? { |vt| vt.fields.count == 0 }
```


# validations 

```ruby
:name, presence: true, uniqueness: { case_sensitive: true }

validates :in_stock,
  inclusion: { in: [true, false] },
  allow_nil: true  # there is also allow_blank: true

validates :in_stock,
  exclusion: { in: [nil] },
  on: :create  # on create means only when creating resource

validates :email, format: { with: /\ A([ ^@\ s] +)@((?:[-a-z0-9] +\.) +[a-z]{ 2,})\ Z/ i }

validates_length_of :essay,
  minimum: 100,
  too_short: 'Your essay must be at least 100 words.',
  tokenizer: ->(str) { str.scan(/\w+/) } # Specifies how to split up the
             # attribute string. (e.g. tokenizer: ->(str) { str.scan(/\w+/) } to count
             # words). Defaults to ->(value) { value.split(//) }
             # which counts individual characters.
```


## disable readonly on scope

any record loaded via join loaded  will be readonly (piggy back object)

```ruby
class FieldValue < ActiveRecord::Base
  default_scope { joins(:field).readonly(false).merge(Field.positioned) }
end
```

this will ensure tha when you call `Whatever.field_values.create(foo: 'bar)` the reccord
is writable

## ways to set attributes

```ruby

user.assign_attributes( { foo: 'bar' } )

```

## has one examples

```ruby

as_one :credit_card, dependent: :destroy  # destroys the associated credit card
has_one :credit_card, dependent: :nullify  # updates the associated records foreign
                                              # key value to NULL rather than destroying it
has_one :last_comment, -> { order 'posted_on' }, class_name: "Comment"
has_one :project_manager, -> { where role: 'project_manager' }, class_name: "Person"
has_one :attachment, as: :attachable
has_one :boss, readonly: :true
has_one :club, through: :membership
has_one :primary_address, -> { where primary: true }, through: :addressables, source: :addressable
```

source: 

* http://apidock.com/rails/ActiveRecord/Associations/ClassMethods/has_one

## PostgreSQL select duplicates only

```ruby
class Application < ActiveRecord::Base
  scope :have_duplicates, -> { where 'domain in (SELECT domain FROM applications GROUP BY domain HAVING COUNT(domain) > 1)' }
end
```

## Directly execute sql

```ruby
ActiveRecord::Base.establish_connection
ActiveRecord::Base.connection.execute('select * from ...')
```

directly on model

```ruby
MyModel.find_by_sql('select * from') 
```


## skip rails callbacks

```ruby
Document.skip_callback(:save, :after, :generate_guid)
Document.set_callback(:save, :after, :generate_guid)
```

## Rails empty scope 

```
Validation.none
=> #<ActiveRecord::Relation []> 

oposite to 
Validation.all
=> #<ActiveRecord::Relation [#<Validation id: 1,.....
```


## Joins, Includes and Eager Loading

Eager loading is responsible for prefetching data in one sql query 

    Product.order("name").includes(:category)

    Product.joins(:category, :reviews)
    Product.joins(:category, :reviews => :user)
    Product.joins("left outer join categories on category_id = categories.id")

    products = Product
      .order("categories.name")
      .joins(:categories)
      .select("products.*, categories.name AS category_name")
    products.last.category_name
   


**Fetching one column name from association**

```ruby
# app/models/user.rb
def client_name
  read_attribute("client_name") || client.name
end
```

```
u = User.order("clients.name").joins(:client).select('users.*, clients.name as client_name')
# => SELECT users.*, clients.name FROM `users` INNER JOIN `clients` ON `clients`.`id` = `users`.`client_id` WHERE (`users`.`deleted_at` IS NULL)
u.client_name
```

sources

* http://railscasts.com/episodes/22-eager-loading-revised
* http://guides.rubyonrails.org/active_record_querying.html

Rails: 3.2.13


## Scopes and Arel tricks


```ruby
scope :visible, where("hidden != ?", true)
scope :published, lambda { where("published_at <= ?", Time.zone.now) }
scope :recent, visible.published.order("published_at desc")
scope :desc_order, order(created_at: :desc)

#bad
has_one :custom_form, -> { order('created_at DESC') }, class_name: CustomForm
# SELECT ORDER BY created_at DESC LIMIT 

#good
has_one :custom_form, -> { order(created_at: :desc) }, class_name: CustomForm
# SELECT .... ORDER BY "custom_forms"."created_at" DESC LIMIT 1
```

** merging diferent model scopes **

```ruby
class DocumentVersion
  scope :order_by_latest, ->{ order("document_versions.id DESC") } 
end

class Document
  scope :order_by_latest, ->{ joins(:document_versions).merge(DocumentVersion.order_by_latest) }
end

Document.order_by_latest 
```


** Multiple or Arel scope**

```ruby
scope :with_owner_ids_or_global, lambda{ |owner_class, *ids|
  with_ids = where(owner_id: ids.flatten).where_values.reduce(:and)
  with_glob = where(owner_id: nil).where_values.reduce(:and)
  where(owner_type: owner_class.model_name).where(with_ids.or( with_glob ))
}
```


**complex scope example**

```ruby
class Document
  scope :with_latest_super_owner, lambda{ |o|
    raise "must be client or user instance" unless [User, Client].include?(o.class)
    joins(:document_versions, document_creator: :document_creator_ownerships).
    where(document_creator_ownerships: {owner_type: o.class.model_name, owner_id: o.id}).
    where(document_versions: {latest: true}).group('documents.id')
  }
end
# it can get kinda complex :)
```



**Multiple or with bracket separation**

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
```

```irb
Candy.for_user_or_global(User.last)
#=> SELECT `candies`.* FROM `candies` INNER JOIN `candy_ownerships` ON `candy_ownerships`.`candy_id` = `candies`.`id` WHERE (`candies`.`deleted_at` IS NULL) AND (((`candies`.`type` = 'WorldwideCandies' OR (`candies`.`type` = 'ClientCandies' AND `candy_ownerships`.`owner_id` = 19 AND `candy_ownerships`.`owner_type` = 'Client')) OR (`candies`.`type` = 'UserCandies' AND `candy_ownerships`.`owner_id` = 121 AND `candy_ownerships`.`owner_type` = 'User')))
```

**Arel lower than**

```irb
Event.arel_table[:start_at].lt(Time.now).to_sql
=> "`events`.`start_at` < '2013-03-05 10:38:22'" 
```

**Arel give me records that have empty / no  associations**

```
# give me all users which has no permissions
User.joins('FULL OUTER JOIN permissions on permissions.user_id = users.id').where(permissions: {user_id:nil})
```

**Arel not equal where statement**

```ruby
DocumentVersion.where( DocumentVersion.arel_table[:id].not_eq(11) )
```

**Arel IS NOT NULL**

```ruby
Foo.includes(:bar).where(Bar.arel_table[:id].not_eq(nil))

# non-arel example:
Foo.where('publication_id IS NOT NULL')
```

**Select Clients that have more that have existing documents**

```ruby
class Client < ActiveRecord::Base
  has_many :documents
  scope :with_existing_documents, ->{ Client.joins(:documents).where(Document.arel_table[:client_id].eq( Client.arel_table[:id]) ).uniq }
end
```

```ruby
class Document < ActiveRecord::Base
  belongs_to :client
end
```

however when you think about it `Client.joins(:documents).uniq` already do that job by it's own

```ruby
 # ...
 scope :with_existing_documents, ->{ Client.joins(:documents).uniq }
 #...
```

so 

```ruby
doc = Document.create
client_without  = Client.create
client_with_doc = Client.create( documents: [doc]
Client.with_existing_documents
# => [client_with_doc]
```


Sources:

* http://stackoverflow.com/a/16014142/473040
* https://github.com/rails/arel/tree/master/lib/arel/nodes
* https://github.com/rails/arel

Rails 3.2.13

## Updating attributes, columns, and touching stuff

* `update_attribute` skips validations, but will touch updated_at and execute callbacks.

* `update_column` skips validations, does not touch updated_at, and does not execute callbacks.

so  if you want to update column without triggering  anything do use `update_column`, good 
example is writing your own touch method

```ruby
def my_touch   
  update_column :cache_changed_at, send(:current_time_from_proper_timezone)
end
```

if you need to touch field with time

    # out of the box touch will run with validations
    touch(:cache_changed_at)  #watch out this will update `updated_at` as well

    UPDATE `documents` SET `updated_at` = '2013-08-20 11:46:28', `cache_canged_at` = '2013-08-20 11:46:28' WHERE `documents`.`id` = 10
    

with no args touch will touch `updated_at`

source : http://stackoverflow.com/a/10824249/473040, http://apidock.com/rails/ActiveRecord/Timestamp/touch



## how to detect if column exist in Rails ActiveRecord

Columns are automaticly transformed into methods for instances of thot
Model.
That mean you can do 

    event = Event.last
    event.respond_to?(:updated_at)
    # true

There may be an issues if you writing Rails engine because if model have
method
with same name, it will return true even if column doesn't exist

So more acurate way is to ask like this:

     event = Event.last
     event['updated_at'].present?  # => true 

This is directly asking instance "what is the value of a column". 

If you don't want to trigger sql query to fetch the value of a column
but you rather 
ask model class directly if the column exist you can do this:

     Event.column_names.include?('updated_at') 


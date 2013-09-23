# Rails Active Record Scrapbook


## Joins, Includes and Eager Loading

Eager loading is responsible for prefetching data in one sql query 

    Product.order("name").includes(:category)

    Product.joins(:category, :reviews)
    Product.joins(:category, :reviews => :user)
    Product.joins("left outer join categories on category_id = categories.id")



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
```


** Multiple or Arel scope **

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

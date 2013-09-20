# Joins, Includes and Eager Loading

Eager loading is responsible for prefetching data in one sql query 

    Product.order("name").includes(:category)

    Product.joins(:category, :reviews)
    Product.joins(:category, :reviews => :user)
    Product.joins("left outer join categories on category_id = categories.id")

###Fetching one column name from association

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

# Rails console no database connection

if this happens to you right after you load Rails 4 console:

```bash
rails c
```

```ruby
User
 => User(no database connection)
```

It just means that ActiveRecord  has not yet connected to the database and therefore does not know the column information.
This is so that will not connect to DB unless needed to (speed improvements in Rails 4). 

to connect just call

```ruby
User.connection

# or

User.last
```

Rails 4

source: http://stackoverflow.com/a/19887408


Shown at 

http://ruby-on-rails-eq8.blogspot.co.uk/2014/04/rails-console-no-database-connection.html

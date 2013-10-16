# MySQL

### Index

```sql
show index in my_table;
drop index dn_ownerships_ix on my_table;

```

### Import & export in MySQL

**importing sql file**

    mysql -u root -p rails_development < rails.db 

**exporting sql file**

   mysqldump gtld_dashboard_development -uroot -p > foo.db

### general mysql commands 

~~~sql
show databases;
show tables;
drop database database_name;
create database database_name;
use database_name;
desc table;

select count(*) from categories;
~~~

# PostgreSQL

# Rails migrations

### Add and remove index

```ruby
class AddDocumentNameOwnershipIndex < ActiveRecord::Migration
  def up
    add_index :document_name_ownerships, 
      [:owner_type, :owner_id],
      name: :dn_ownerships_ix, 
      uniq: true
  end

  def down
    remove_index :document_name_ownerships, name: :dn_ownerships_ix
  end
end
```

Note: multiple inxexes are read from left to right

* http://dev.mysql.com/doc/refman/5.0/en/multiple-column-indexes.html
* http://stackoverflow.com/questions/13298545/how-to-specify-a-multiple-column-index-correctly-in-rails



# Other Rails db tricks

### Random record in mysql

~~~ruby
Person.find(:first, :order => 'rand()')
Model.first(:order => "RANDOM()") 
Thing.order("RANDOM()").first
Thing.offset(rand(Thing.count)).first
Recommendation.offset(rand(Recommendation.count)).where('person_id != 1').first
~~~

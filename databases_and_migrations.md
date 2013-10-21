# MySQL

**restart mysql in Ubuntu like system**

    /etc/init.d/mysql restart
    # or ..
    /etc/init.d/mysqld restart

**startup  mysql databese client **
```
mysql my_database -uroot -p

```

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

### MySQL Index

```sql
ANALYZE TABLE my_table
SHOW INDEX IN my_table;                   #show index on table
```

to get inmmiditae cardinality you can do:

```
SELECT COUNT(DISTINCT age) AS cardinality FROM user;
```

to drop an index you can do:

```
DROP INDEX dn_ownerships_ix on my_table;
```


to test performance use:
  
    EXPLAIN SELECT * FROM whatever_table;

however you'll probably need to disable caching 

    SHOW VARIABLES LIKE 'query_cache_size';
    SET GLOBAL query_cache_size =   0;
    SHOW VARIABLES LIKE 'have_query_cache';
    
and restart mysql server

sources 

*  http://webmonkeyuk.wordpress.com/2010/09/27/what-makes-a-good-mysql-index-part-2-cardinality/

### MySQL DISTINCT 


    SELECT DISTINCT City FROM Customers; 
    
    
keywords: mysql select uniq (distinct, non-duplicate) items with SELECT DISTINCT


### Import & export in MySQL

**importing sql file**

    mysql -u root -p rails_development < rails.db 

**exporting sql file**

   mysqldump gtld_dashboard_development -uroot -p > foo.db



###change password on mysql user

    use mysql;
    update user set password=PASSWORD("NEW-PASSWORD-HERE") where User='tom';


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

### Trigger direct mysql command from rails

~~~ruby
ActiveRecord::Base.connection.execute("TRUNCATE #{ApplicationBuildCommand.table_name}")  
~~~

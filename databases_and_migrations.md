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

**hash index**

from: http://stackoverflow.com/questions/3567981/how-do-mysql-indexes-work/3568214#3568214

to index big string (like url) create column e.g.: `url_hash` and store there CRC version of string 

     SELECT url FROM url_table WHERE url_hash=CRC32("http://gnu.org") AND url="http://gnu.org";

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

### general notes

    postgress -D /var/local/var/pg_db -! /tmp/pglog # -D specify  vher db is saved, -l where log is  saved
    psql
      \d  #list databases
      \d  my_db  #list tables of db 
      \d  table  #list colums
      \l    #list all databases
      

    mysql:  use database_name;
    postgres: \c database_name;
        
    mysql: SHOW TABLES
    postgresql: \d
    postgresql: SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

    mysql: SHOW DATABASES
    postgresql: \l
    postgresql: SELECT datname FROM pg_database;

    mysql: SHOW COLUMNS
    postgresql: \d table
    postgresql: SELECT column_name FROM information_schema.columns WHERE table_name ='table';

    mysql: DESCRIBE TABLE
    postgresql: \d+ table
    postgresql: SELECT column_name FROM information_schema.columns WHERE table_name ='table';


    rails new --database=postgres
    gem 'pg'
    1255


### fedora start postgress

      psql --username=postgres

### mint & ubuntu postgres 
    
    sudo -u postgres psql
    # be sure to include host=localhost in config/database.yml with ubuntu

    # How to start / stop the server?
    sudo service postgresql start / stop
    sudo /etc/init.d/postgresql start / stop
 
source: https://zxmax.wordpress.com/2012/05/26/install-postgers-9-3-on-ubuntu-12-04/

 
### mint ubuntu start login to postgress   
     psql -d postgres -U postgres --password --host=localhost


### create database
    
      CREATE USER tom WITH PASSWORD 'myPassword';
      CREATE DATABASE jerry;
      GRANT ALL PRIVILEGES ON DATABASE jerry to tom;



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

### Explain queries for Arel in Rails console

```ruby
Document.where(id: 1).explain
# => EXPLAIN SELECT `documents`.* FROM `documents` WHERE `documents`.`id` = 1 AND (`documents`.`deleted_at` IS NULL)
```

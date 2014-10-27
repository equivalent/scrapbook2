# PostgreSQL

### array 

to create rails migration for array  (it can be text as well as postgres will make it array)

http://www.postgresql.org/docs/9.1/static/arrays.html

```
  create_table "email_logs" do |t|
    t.integer  "user_tld_id"
    t.string   "category",       default: [], array: true
  end
```


#### array search

```
SELECT  "email_logs".* FROM "email_logs" WHERE user_tld_id = 3 AND 'reminder' = ANY (category) LIMIT 1;
```

### Functions

```sql
CREATE FUNCTION add_em(integer, integer) RETURNS integer AS $$
    SELECT $1 + $2;
$$ LANGUAGE SQL;

SELECT add_em(1, 2) AS answer;


CREATE FUNCTION domain_count(text) RETURNS bigint AS $$
  SELECT COUNT(*) FROM "applications" WHERE "applications"."domain" = $1;
$$ LANGUAGE SQL;

SELECT domain_count('developer-test.com') AS domain_count;

```


### export query to csv 

```sql

Copy (Select * From foo) To '/tmp/test.csv' With CSV;
```

source: http://stackoverflow.com/questions/1517635/save-postgres-sql-output-to-csv-file

### duplicate 

```sql
# what domains are duplicated
SELECT domain FROM applications GROUP BY domain HAVING COUNT(domain) > 1;

   domain   
------------
 joe.com    
 zoe.com    


# therefore 
select * from applications where domain in (SELECT domain FROM applications GROUP BY domain HAVING COUNT(domain) > 1);


# select every column of fields that are duplicated BUT ONLY ONE OF EACH
# solution look nice but you may face several issues
#
SELECT * FROM (select * ROW_NUMBER() OVER(PARTITION BY domain) AS domain_count FROM applications) dups WHERE dups.domain_count > 1;
   domain   | domain_count  |
------------+-------------- |
 joe.com    |            3  |
 zoe.com    |            2  |

```

### general notes

    postgress -D /var/local/var/pg_db -! /tmp/pglog # -D specify  vher db is saved, -l where log is  saved
    psql
      \d  #list databases
      \d  my_db  #list tables of db 
      \d  table  #list colums
      \l    #list all databases
      
      \du # list all users
      

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


### Dump

#### Load dump

```bash
 sudo -u postgres psql db_name < dump.db 
```

#### create dump

```bash
pg_dump db_name > dump.db
```

http://www.postgresql.org/docs/9.1/static/backup-dump.html

### create database & user & change root password
    
      CREATE USER tom WITH PASSWORD 'myPassword';
      CREATE DATABASE jerry;
      GRANT ALL PRIVILEGES ON DATABASE jerry to tom;
      
      ALTER USER postgres WITH PASSWORD 'happyface';
      
      \du  # list all users
      DROP USER username;  #you need to change owner of databases first
      
      # change owner of database
      ALTER DATABASE name OWNER TO new_owner;
      
      # rename user 
      ALTER USER name RENAME TO newname;


higher changes with user in Postgress

      
      ALTER USER myuser WITH SUPERUSER; # will be superuser
      ALTER USER myuser WITH CREATEDB;  # can create db

http://www.postgresql.org/docs/current/static/sql-alterdatabase.html



### fedora start postgress

      psql --username=postgres

### Install postgresql 9.1 on Ubuntu 12.04
    
http://railskey.wordpress.com/2012/05/19/postgresql-installation-in-ubuntu-12-04/
    
    sudo apt-get install python-software-properties
    sudo add-apt-repository ppa:pitti/postgresql
    sudo apt-get update
    sudo apt-get install postgresql-9.1 libpq-dev
    
    #check instalation
    locate postgresql
    psql -V
    

### mint & ubuntu postgres 
    
    sudo -u postgres psql 
    
    # be sure to include host=localhost in config/database.yml with ubuntu

    # How to start / stop the server?
    sudo service postgresql start / stop
    sudo /etc/init.d/postgresql start / stop
    
### mac OSx postgres console 

    sudo -u tomi psql postgres    # tomi represent system user
 
source: https://zxmax.wordpress.com/2012/05/26/install-postgers-9-3-on-ubuntu-12-04/

 
### mint ubuntu start login to postgress   
     
     sudo -u postgres psql  # login from root
     
     psql -d postgres -U postgres --password --host=localhost


### add hstore to database


    sudo -u postgres psql my_app_development
    
    create extension hstore;

if you get `PG::Error: ERROR:  could not open extension control file "/usr/share/postgresql/9.1/extension/hstore.control": No such file or directory
: CREATE EXTENSION IF NOT EXISTS hstore` run:

    sudo apt-get install postgresql-contrib

source http://stackoverflow.com/questions/19467481/postgres-hstore-exists-and-doesnt-exist-at-same-time

#### postgres hstore queries

```ruby
Product.create(properties: {rating: 'PG-13', runtime: '103'} )

Product.where("properties -> 'rating' = 'PG-13'")
Product.where("properties -> 'rating' LIKE '%G%'")
Product.where("(properties -> 'rating')::int > 100")

```

Rails Hstore object has different Object ID  each time you call it, so you
cannot do this:

```ruby
foo.properties['rating'] = '123' # wont save
foo.properties # => {}
```

...you need to set the full properties hash each time

```ruby
foo.properties  { rating: 'foo'}
```

...so to do setra method you need to have 

```ruby
def author=(value)
  self.properties = (properties || {}).merge(author: value)
end
```

sources:

* railscasts-345

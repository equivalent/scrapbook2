# PostgreSQL


```
$ sudo -u postgres dropdb development_app
$ sudo -u postgres createdb development_app
$ sudo -u postgres pg_restore  --dbname=development_app  dump.dump 
```


* [upsert feature](http://git.postgresql.org/gitweb/?p=postgresql.git;a=commit;h=168d5805e4c08bed7b95d351bf097cff7c07dd65)  (INSERT ... ON CONFLICT  UPDATE)


### debug postgres huge cpu usage

```
SELECT * FROM pg_stat_activity;
```


once you find proces causing issue (usually one stuck there `active`
for hours)  kill it

```
  # SELECT pg_cancel_backend(pid-of-the-postgres-process);   # 3rd line of pg_stat_activity;
  SELECT pg_cancel_backend(123456);  
```

in docker container

```
psql --username="$DB_ENV_POSTGRES_USERNAME" --host="$DB_PORT_5432_TCP_ADDR" --dbname="$DB_ENV_POSTGRES_DATABASE" -c 'SELECT * from pg_stat_activity ;'  --password >> /tmp/out.txt
```





### Rails time gt date lt

```ruby
MyModel.where('"created_at" > ?', Time.new(2015).to_s(:db))
```

### clusters and upgrading postgres


command that will give you information on existing clusters

```bash
sudo pg_lsclusters
```

[ upgrade from 9.1 to 9.3](http://nixmash.com/postgresql/upgrading-postgresql-9-1-to-9-3-in-ubuntu/)


```bash
sudo pg_lsclusters
sudo pg_dropcluster --stop 9.3 main #  delete the default 9.3 cluster created by the 9.3 install.
sudo pg_upgradecluster 9.1 main     #  create a new 9.3 cluster from the existing 9.1 cluster
sudo service postgresql start 9.3
sudo pg_dropcluster --stop 9.1 main      # delete the 9.1 Cluster.
```


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

in heroku

```

pg_restore --verbose --clean --no-acl --no-owner -h localhost -U myuser -d mydb latest.dump
# ..or
 sudo -upostgres pg_restore --verbose --clean --no-acl --no-owner -d mydb latest.dump
```

`pg_dump` for `pg_restore` the dump must be in `tar` format so e.g.
`pg_dump --format=t` 

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



### Install postgresql 9.3 on Ubuntu 14.04
    

    sudo apt-get update
    sudo apt-get install postgresql-9.3 libpq-dev
    
    #check instalation
    locate postgresql
    psql -V
    
for Ubuntu 12.04 & postgres 9.1 check http://railskey.wordpress.com/2012/05/19/postgresql-installation-in-ubuntu-12-04/


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

## moving postgres datastore location

```bash
sudo su postgres
psql
>    SHOW data_directory;
```

let say `/var/lib/postgresql/9.3/main/postgresql.conf`

```bash
mkdir -p /mnt/database_volume/postgres
chown -R postgres:postgres /mnt/database_volume/postgres

/usr/lib/postgresql/9.1/bin/initdb -D /mnt/database_volume/postgres # this will init the dir structure
```

now `vim /etc/postgresql/9.3/main/postgresql.conf` 

... and change:

```
data_directory = '/var/lib/postgresql/9.3/main/'
```

... to:

```
data_directory = '/mnt/database_volume/postgres/'
```

Now kill postgress (`killall -9 postgre`)

... and start it `sudo /etc/init.d/postgresql restart`

If you need to remove system autostart (e.g. your `/mnt/database_volume`
is encrypted) you can do it by remonig rc-d 

```bash
sudo update-rc.d -f postgresql remove`
```

source:

* http://www.whiteboardcoder.com/2012/04/change-postgres-datadirectory-folder.html
* http://askubuntu.com/questions/25713/how-to-stop-postgres-from-autostarting-during-start-up

### pure Postgres JSON API

http://blog.redpanthers.co/create-json-response-using-postgresql-instead-rails/

```sql
select row_to_json(users) from users where id = 1;
```

```json

{"id":1,"email":"hsps@redpanthers.co","encrypted_password":"iwillbecrazytodisplaythat",
"reset_password_token":null,"reset_password_sent_at":null,
"remember_created_at":"2016-11-06T08:39:47.983222",
"sign_in_count":11,"current_sign_in_at":"2016-11-18T11:47:01.946542",
"last_sign_in_at":"2016-11-16T20:46:31.110257",
"current_sign_in_ip":"::1","last_sign_in_ip":"::1",
"created_at":"2016-11-06T08:38:46.193417",
"updated_at":"2016-11-18T11:47:01.956152",
"first_name":"Super","last_name":"Admin","role":3}
```

specific fields:

```sql
select row_to_json(results)
from (
  select id, email from users
) as results
```

```json
{"id":1,"email":"hsps@redpanthers.co"}
```

more advanced

```sql
select row_to_json(result)
from (
  select id, email,
    (
      select array_to_json(array_agg(row_to_json(user_projects)))
      from (
        select id, name
        from projects
        where user_id=users.id
        order by created_at asc
      ) user_projects
    ) as projects
  from users
  where id = 1
) result
```

```json
{"id":1,"email":"hsps@redpanthers.co", "project":["id": 3, "name":"CSnipp"]}
```

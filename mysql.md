# MySQL


**restart mysql in Ubuntu like system**

    /etc/init.d/mysql restart
    # or ..
    /etc/init.d/mysqld restart

**startup  mysql databese client **
```
mysql my_database -uroot -p

```

### reset root mysql password

https://help.ubuntu.com/community/MysqlPasswordReset

```bash
sudo /etc/init.d/mysql stop
sudo /usr/sbin/mysqld --skip-grant-tables --skip-networking &
mysql -u root  # now you can connect without passwor
```

```sql
   FLUSH PRIVILEGES;
   SET PASSWORD FOR root@'localhost' = PASSWORD('password');    
   UPDATE mysql.user SET Password=PASSWORD('newpwd') WHERE User='root';   
   FLUSH PRIVILEGES;
   SELECT User FROM mysql.user;  # all mysql users
```

```bash
sudo /etc/init.d/mysql stop
sudo /etc/init.d/mysql start
```

### rename mysql database

aparently there is no such thing you have to 

```

    mysqldump -u root -p originl_database > original_database.sql
    mysql -u root -p -e "create database my_new_database"
    mysql -u root -p my_new_database < original_database.sql
    myqsl -u root -p -e "GRANT ALL ON db1.* TO 'jeffrey'"
    mysql -u root -p -e drop database originl_database
```

http://stackoverflow.com/questions/12190000/rename-mysql-database
   
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


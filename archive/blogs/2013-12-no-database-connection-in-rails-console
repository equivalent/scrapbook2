# Rails console responding with (no database connection) with PostgreSQL

if this happens to you:

    rails c
    > User
    > => User(no database connection)

It just means that ActiveRecord  has not yet connected to the database and therefore does not know the column information.
This is so that will not connect to DB unless needed to (speed improvements). 

to connect just call

    > User.connection


Rails 4

source: http://stackoverflow.com/a/19887408

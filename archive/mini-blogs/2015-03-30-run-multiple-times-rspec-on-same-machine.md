# Run multiple instances of RSpec on same machine

Sime times you are stuck with realy badly written Rails project (or other application which comunicates
with Database) which entire test suite takes ages to run.
You want to run all the tests but you while they running you want to continue your TDD work.

If you run RSpec multiple times (multiple instances at a same time) you may break one of test suits because you 
will write data to same database both RSpec instances are comunicating with.

One way to handle this is if you run rspecs on different databases


```
# config/database.yml
default: &default
  adapter: mysql2
  encoding: utf8
  reconnect: false
  pool: 5
  username: root
  password: my_development_password
  socket: /var/run/mysqld/mysqld.sock

development:
  <<: *default
  database: myapp_development

test:
  <<: *default
  database: myapp_test<%= ENV['TEST_ENV_NUMBER'] %>
```

```sh
 RAILS_ENV=test TEST_ENV_NUMBER=2 rake db:create
 RAILS_ENV=test TEST_ENV_NUMBER=2 rake db:migrate

 TEST_ENV_NUMBER=2 rspec spec/
```

 If you are looking for solution how to run same test suite on multiple databases check https://github.com/grosser/parallel_tests

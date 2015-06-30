

```
# .travis.yml
language: ruby
rvm:
  - 1.9.2
  - 1.9.3
env:
  - DB=sqlite
  - DB=mysql
  - DB=postgresql
script: 
  - RAILS_ENV=test bundle exec rake db:migrate --trace
  - bundle exec rake db:test:prepare
  - bundle exec rspec spec/
before_script:
  - mysql -e 'create database my_app_test'
  - psql -c 'create database my_app_test' -U postgres
bundler_args: --binstubs=./bundler_stubs
```

source:

* http://stackoverflow.com/questions/10591599/rake-dbmigration-not-working-on-travis-ci-build

# YAML 

### yaml symbols 

test1.yml

```yaml
foo: 'bar'
car: 'dar'
```

test2.yml

```yaml
:foo: 'bar'
:car: 'dar'
```

```ruby
require 'yaml'
test1 = Yaml.load_file('test1')
test2 = Yaml.load_file('test2')

test1.fetch('foo') # => 'bar'
test1.fetch(:foo)  # => nil
test2.fetch(:foo)  # => 'bar'
```

source: ruby tapas 023

### yaml defaults / shared context

```
default: &default 
  host:    localhost
  adapter: postgresql
  encoding: unicode
  pool: 5
  username: developer
  password: foobar

development:
  <<: *default
  database: my_app_development

production:
  <<: *default
  database: my_app_development
```

note Rails evaluate `config/database.yml` as ERB too so you can pass
erb:

```yaml
test:
  <<: *default
  database: my_app_test<%= ENV['TEST_ENV_NUMBER'] %>
```







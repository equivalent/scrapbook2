# Some debugging tips for Ruby on Rails

This article will be  updated on regular bases.  

## Pry

http://pryrepl.org/

Pry is awesome console tool. Onece installed you can run `rails c` and
you can inspect objects (e.g.: `ls User.last`)

But key benefit is using pry as a debugger tool


```ruby
# app/model/user.rb

class User < ActiveRecord::Base
  def do_stuff
    a = 3
    require 'pry'; binding.pry
    return a
  end
end
```

Next time you do something with `User#do_stuff` in web-browser, `pry`
console will pop-up in your server (`rails s`) and you can debug code
like with `ruby debugger`

> ruby debugger had some issues in the past specially with
> maintainability. That's why you see Ruby developers prefering `pry`


## Get the Active Record (Rails) db configuration

from `rails c`

```ruby
ActiveRecord::Base.connection.instance_variable_get(:@config)
```

## Establish connection with ActiveRecord

Sometimes you want to test the connection to your relational database (MySQL, PostgreSQL,...)
without loading entire Ruby on Rails with `rails c`. What you can do is:

#### check from irb

```bash
cd ./my-rails-app && irb
```

```ruby
require 'active_record'
require 'yaml'
require 'erb'

rails_env = 'production' # change me

conf = YAML.load(ERB.new(File.read("config/database.yml")).result)
ActiveRecord::Base.establish_connection(conf.fetch(rails_env))
ActiveRecord::Base.connection
```

#### One liner with ruby -e

```bash
# cd ./my-rails-app

bundle exec ruby -e 'require "active_record"; require "yaml"; require "erb"; ActiveRecord::Base.establish_connection(YAML.load(ERB.new(File.read("config/database.yml")).result).fetch("production")).tap { |ar| ar.connection && puts("success") }'
```

Other sources:

* https://github.com/rails/rails/tree/master/activerecord

## Establish connection with Redis

Sometimes you want to test the connection to your Redis serer without loading
entire Ruby on Rails with `rails c`. What you can do is:

#### check from irb

```bash
cd ./my-rails-app && irb
```

```ruby
require 'redis'

Redis.new(host: 'localhost', port:'6379', db: 0).keys[0]
```

#### One liner with ruby -e

```bash
# cd ./my-rails-app

bundle exec ruby -e 'require "redis"; Redis.new(host: "localhost", port:"6379", db: 0).keys[0]'
```

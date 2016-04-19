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


## Edit locally used gem and rollback to original state.

Imagine you need to debug why your application fails on a gem level.
If you are using [bundler](http://bundler.io/) you can open locally used
gem (Development env) like this:

`EDITOR=editor_executable bundle open gem_name`

Example:

```bash
cd ./my-ruby-project
EDITOR=vim bundle open sidekiq
```

Let say you want to know what is the value of certain argument passed
during initialization of your gem. Stick a `binding.pry` there:

```bash
         # /home/user/.rvm/gems/ruby-2.3.0@my-ruby-project/gems/sidekiq-4.1.1/lib/sidekiq/cli.rb
@ line 364 Sidekiq::CLI#parse_config:
    358: def parse_config(cfile)
    359:   opts = {}
    360:   if File.exist?(cfile)
    361:     opts = YAML.load(ERB.new(IO.read(cfile)).result) || opts
    362:     opts = opts.merge(opts.delete(environment) || {})
    363:     parse_queues(opts, opts.delete(:queues) || [])
 => 364:     require 'pry'; binding.pry
    365:   else
```

Restart the server (in this case Sidekiq) and debug what you need.

Then when finished you can either manually remove your changes or run
`gem pristine gem_name` to roll back the original state.

Example

```bash
gem pristine sidekiq
# Restoring gems to pristine condition...
# Restored sidekiq-4.1.1
```


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

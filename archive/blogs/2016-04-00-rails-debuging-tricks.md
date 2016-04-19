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

## curl Puma/Unicorn socket

Usually your webserver (Puma, Unicorn, ...) is behind loadbalancer/proxy-server like NginX.

Therefore you can do:

```bash
curl http://my-website.co
```

...and you NginX will forward your request to WebServer (Puma) and that will retur response again via NginX.

The problem is that simetimes you want to check if there is any problem between WebServer and NginX.

If your NginX setup is forwarding requests to `localhost:3000` then no
problem, all you have to do is ssh to server and do make a request
from there:

````bash
ssh my-user@my-server.com
curl localhost:3000/welcome
```

However Common practice (I would argue best-practice) in NginX world is to forward requests to the WebServer via a socket rather than
url.

Therefore you need to `curl` on a socket.

```bash
ssh my-user@my-server.com
curl --unix-socket /var/sockets/my-puma.sock  http:/welcome
```

Check your NginX configuration file to ensure where to `curl` to.

> NginX configuration fiele is usually located in `/etc/nginx/nginx.conf`,
> `/opt/nginx/nginx.conf` or in sub conf. files
> `etc/nginx/sites-enabled/default`

Curl `--unix-socket` is there from version `7.40` so if you getting
error: `curl: option --unix-sock: is unknown` there is another option:

```bash
# using socat
echo -e "GET /welcome HTTP/1.1\r\n" | socat unix-connect:/var/sockets/pobblecom.sock STDIO

# using netcat
echo -e "GET /welcome HTTP/1.0\r\n" | nc -U /var/sockets/my-puma.sock
```

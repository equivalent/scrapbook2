# Rails redirects to wrong host (NginX `HTTP_X_FORWARDED_HOST`)

The other day I noticed a problem on our beta server
(let's call it `qa.ourapplication.it`): Some controllers were redirecting
to production (let's call it `www.ourapplication.com`).

This happened due to fact that entire Rails application was hardcoding
`*_url` (like `root_url`, `welcome_url`, ...) and I've replace them to
be `*_path` (like `root_path`, `welcome_path`,...).

This should not be an issue for Rails application as long as
`default_url_options` `host` is set to correct location. So let's have a
look:


```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # ...

  def default_url_options
    case Rails.env
    when 'production'
      { host: 'www.ourapplication.com' }
    when 'qa'
      { host: 'qa.ourapplication.it' }
    # ...
    else
      { host: 'localhost:3000' }
    end
  end

  # ...
end
```

http://apidock.com/rails/ActionController/Base/default_url_options


> Note: Configuring  this in a controller is ok
> but better practice to configure it in `config/enviroments/qa.rb` like
> `config.action_controller.default_url_options = { host: 'qa.ourapplication.it' }`.
> Or if you really want to have it in a controller,  configure `config.x.app_host =`'qa.ourapplication.it'
> and in `ApplicationController` let method `default_url_options`
> to return hash like `{ host: Rails.application.config.x.app_host }`


Looks ok to me.

So lets have a look into NginX config:

```nginx
upstream ourapplication {
  server unix:///shared/sockets/ourapplication.sock;
}

server {
  listen                80;
  server_name           www.ourapplication.com qa.ourapplication.it;
  root                  /app/public;

  # ...

  location / {

    proxy_set_header  Host $host;
    proxy_set_header  X-Real-IP $remote_addr;
    proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header  X-Forwarded-Host $server_name;
    proxy_set_header  Client-IP $remote_addr;
    proxy_pass        http://ourapplication;
  }

  # ...
```

So all should be good ! What is  happening here ?

Lets do some debugging and print out the entire `request.inspect` to the Rails logs to see
what's happening

```ruby
class WelcomeController < ApplicationController
  # ...
  def index
    Rails.logger.info request.inspect

    # ...
  end
  # ...
end
```

```bash
tail -f log/qa.log
```

> Note: If you use Docker + Nginx + Puma and if you need to debug running docker
> container, you don't have to
> deploy new image or commit running container with a change in a file.
> All you have to do is get inside running docker container ,
> (`sudo docker ps; sudo docker  exec -it 1234MyContainerId bash`)
>  and once inside do a file change and then run `pumactl restart` that
> will reload Puma workers with file change without killing Docker container.


...and this is what popped out (inside qa.ourapplication.it):

```
# ...
"HTTP_HOST"=>"qa.ourapplication.it", "HTTP_X_REAL_IP"=>"81.11.111.148",
"HTTP_X_FORWARDED_FOR"=>"81.11.111.148",
"HTTP_X_FORWARDED_HOST"=>"www.ourapplication.com",
"HTTP_CLIENT_IP"=>"81.91.247.148", "HTTP_CONNECTION"=>"close", "HTTP_USER_A
# ...
@delete_cookies={},
@host="www.ourapplication.com",
@secure=false,
# ...
```

Look at the `HTTP_X_FORWARDED_HOST`

This make sense, `X-Forwarded-Host` is being passed for the first
server of our NginX configuration `www.ourapplication.com` and Rails is using this header to
change the default host.

http://calvincorreli.com/2005/12/05/what-s-with-http_x_forwarded_host/comment-page-1/


### Solution

So either remove `proxy_set_header  X-Forwarded-Host $server_name;`
if you don't necessarily need  header `HTTP_X_FORWARDED_HOST`,
or [extract servers to individual blocks and include commonalities](https://kcode.de/wordpress/2033-nginx-configuration-with-includes) like this:


```
upstream ourapplication {
  server unix:///shared/sockets/ourapplication.sock;
}

server {
  listen                80;
  server_name           www.ourapplication.com:

  include /etc/nginx/includes/ourapp-redirects;
  include /etc/nginx/includes/ourapp-rootlocation;
}

server {
  listen                80;
  server_name           qa.ourapplication.it:

  include /etc/nginx/includes/ourapp-redirects;
  include /etc/nginx/includes/ourapp-rootlocation;
}
```

This way you will ensure proper `server_name` block gets triggered and
therefore proper host passed as `HTTP_X_FORWARDED_HOST`


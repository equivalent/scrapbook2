# Authenticated Sessions should not be Transferable (or should they ?)

solution : "Incorporate Client Identifiers Within Session Data"

```
Consider implementing a mechanism to detect session
tokens being moved between client machines

* user agent changing (browser)
* ip chang
```

basically the premiss is to map session ids to IP adresses however there is lot of discussion on how this may be an overkill http://stackoverflow.com/questions/618301/binding-of-ip-address-with-session-id

especially: 

```
 if you want to use it as a general session ID, you might have problem to deal with users behind a certain proxy gateway, where all users will have the same IP address. although it could be used to prevent session theft (using techniques like cookie highjacking) for some level. but it should be considered that the cookie hijacker can also mimic the IP address of the victim. so checking the user session and also the IP address can be a good practice to have a higher security, but is not a bullet proof solution.
```

in other words if you building nuclear misle application it make sence but you are better of just whitelisting IP addresses that can access the site on a firewall

one good approach is just to map changes of IP addresses and Browser changes analized in backgorund job and then just force them to verify (like caling client manager number)

# secure XSS file name

try to upload located in  `scrapbook2/assets/XSSfile.<a onmouseover="alert(1)">a`



# Use Secure Cookies

Ensure that the secure flag is set on all cookies that are
used to maintain user state or have any security impact, and
that all sensitive data is transmitted over HTTPS.

Also ensure that any redirects from HTTPS pages redirect to
HTTPS and not HTTP pages.

**fix** 

you can do 

```ruby
# in config/environment.rb:
config.action_controller.session = {
    :key    => '_myapp_session',
    :secret => 'super_very_long_key_more_than_30_chars',
    :expire_after => 3600 # 1 hour
  }
```

and for devise:

```
# config/initializers/devise.rb
config.rememberable_options = { secure: true }

```

...HOVEVER the thing abount flaging cookies with secure flag is pointless
there as the whole cookie store is bad, so better use some other type of storage(ActiveRecord db, Redis,
Memcache) [more info here](http://dev.housetrip.com/2014/01/14/session-store-and-security/)

```ruby
# config/initialzers/session_store.rb


## old no-no cookie way 
# MyProject::Application.config.session_store :cookie_store, key:
'_my_project_session'

Rails
  .application
  .config
  .session_store ActionDispatch::Session::CacheStore, :expire_after => 20.minutes
```

https://github.com/mperham/dalli#usage-with-rails-3x-and-4x


# Ensure that all requests use HTTPS use:

```ruby
  # confix/environmets/production.rb  && staging

  config.force_ssl = true
```

if you need it per controller level

```ruby
class ApplicationController < ActiveController::Base
   force_ssl if: :should_force_ssl?
   
   private
   
   def should_force_ssl?
     !Rails.env.in?(%w(development test))
   end
end

class NonHttpsContoller < ApplicationController
  def should_force_ssl?
    false
  end
end
```

You may have problems with NginX accepting the `force_ssl`. To solve this use 

```
  location @unicorn {
    # ...
    proxy_set_header X-Forwarded-Proto https;
    # ...
  }
```

* http://guides.rubyonrails.org/security.html#session-hijacking
* http://blog.tech-angels.com/post/840662150/ruby-on-rails-secure-cookies
* http://dev.housetrip.com/2014/01/14/session-store-and-security/


# Keep NginX updated

nginx should be updated regulary on server

```
sudo aptitude update
sudo aptitude safe-upgrade

# or if you prefere apt-get

apt-get update
apt-get upgrade      # equivalent of safe-upgrade in aptitude

# if doing kernels
apt-get dist-upgrade

# And Unattended Upgrades for automatic security updates
apt-get install unattended-upgrades #
dpkg-reconfigure unattended-upgrades # enable or disable easity
# configure in /etc/apt/apt.conf.d/50unattended-upgrades
```

source

* http://leftshift.io/upgrading-nginx-to-the-latest-version-on-ubuntu-servers
* my colegue M.H., thx Mike

# NginX disable POODLE

```
# /etc/nginx/nginx.conf

# ...
http {
  # ...
  # disable SSLv3 (POODLE)
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  # ...
}

```

# NginX should not display version 

test it with:

```
http://my-site.com/%%
```

```
# /etc/nginx/nginx.conf

# ...
http {
  # ...
  server_tokens off;
  # ...
}

```

This also disable the version number fromnext check headers in
`server` header. You should hide this header. You can find how to 
remove headers is in  this scapbook note file

source

* https://www.virendrachandak.com/techtalk/how-to-hide-nginx-version-number-in-headers-and-errors-pages/

# Remove Headers

If you compile your own NginX you can compile it with module
`HttpHeadersMoreModule`

and use:

```
more_clear_headers Server Date Status X-UA-Compatible Cache-Control
X-Request-Id X-Runtime X-Rack-Cache;

```

...or if you mange to install `sudo apt-get nginx-extras` working that
module should be included (never tried it )

If you use Nginx from Ubuntu apt-get repo

```
server {

  location @unicorn {

    # ...
    proxy_hide_header X-Powered-By;
    proxy_hide_header X-Runtime;
    # ...
  }
}
```

source:

i* https://stackoverflow.com/questions/10323331/remove-unnecessary-http-headers-in-my-rails-answers/27175020#27175020




source:

http://stackoverflow.com/questions/10323331/remove-unnecessary-http-headers-in-my-rails-answers


# Prevent Page Caching

The pages within authenticated areas of the application
are set to be cached in the browser. After a user has
logged off from the application, these pages are still
accessible within the browser, for example by using the
back button. Within a shared computing environment,
information within authenticated areas is exposed to this
attack.

Caching of pages within the authenticated areas should be
disabled. This can be achieved by returning the following
HTTP headers for all authenticated areas of the application:

```
Cache-Control: no-cache, no-store
Pragma: no-cache
Expires: -1
```

in rails 

* https://github.com/equivalent/no_cache_control

source: 

* http://www.contextis.com/
* http://stackoverflow.com/questions/10744169/rails-set-no-cache-method-cannot-disable-browser-caching-in-safari-and-opera
* http://apidock.com/rails/ActionController/ConditionalGet/expires_in

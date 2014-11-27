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

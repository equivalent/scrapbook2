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

next check headers in

```
# /etc/nginx/nginx.conf

# ...
http {
  # ...
  server_tokens off;
  # ...
}

```

source

* https://www.virendrachandak.com/techtalk/how-to-hide-nginx-version-number-in-headers-and-errors-pages/

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

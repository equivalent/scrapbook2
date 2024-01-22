


Scrapbook2
==============

Pure git/github version of my scrapbook on Ruby on Rails, web-development, linux system configuration.


![](https://i.stack.imgur.com/gJYJv.gif)

> source https://stackoverflow.com/questions/3087975/make-the-cursor-a-hand-when-a-user-hovers-over-a-list-item

    ##########################################################################
    ##                                                                      ##
    ##   Check individual .md files above for more information on topics    ##
    ##                                                                      ##
    ##########################################################################
    
Archive: 
* Blogs are published on [http://www.eq8.eu/blogs](http://www.eq8.eu/blogs)
* Micro Blogs ar published on [http://ruby-on-rails-eq8.blogspot.com/](http://ruby-on-rails-eq8.blogspot.com/)


## tools for developers

* https://tmpfiles.org
* http://dead-drop.me
* https://transfer.sh/


```
# on VM
curl --upload-file /tmp/export.csv https://transfer.sh/
# https://transfer.sh/123456/export.csv

# on Laptop
wget  https://transfer.sh/123456/export.csv
```

## Web-development notes unsorted


### random notes

```
# bin/importmap pin local-time
time_tag post.created_at, 'data-local': 'time-ago'


rails g resource comment post:reference content:text

form.text_area :content, size: '20x5'


<div id="<%= dom_id @post %>" >
</div>

```

### Notice message

```
  <% if quote.errors.any? %>

      <%= @model.errors.full_messages.to_sentence.capitalize %>
  <% end %>
```

### Rails find session_id in rails console

```
#  `app` is variable  and `ENV` a constant loaded when you start rails console
a = Rails.application.config.session_store.new(app, Rails.application.config.session_options)
a.class # => ActionDispatch::Session::RedisStore
a.get_session(ENV, '07319b2485be9ac4850664cd47cede38')  # you can find session id inspecting
                                                        # your cookis via firefox or plugin

# or a.find_session(ENV, '07319b2485be9ac4850664cd47cede38')
```

### generate ri documentation


```bash
rvm docs generate
```

to lunch `ri Array`

### cowsay

```ruby
require 'net/http'
require 'cgi'

class Cowsays
  def say(message)
    message = CGI.escape(message)
    Net::HTTP.get_print(URI.parse(http://www.cowsays.com/cowsay?message=#{message}))
  end
end
```

source: ruby tapas 30

### rails all models

```ruby
Rails.application.eager_load!
ActiveRecord::Base.descendants
```


### include Rails helpers in cusom class

```ruby
class Foo
  include Rails.application.routes.url_helpers
  # ... or you can Delegate methods it
  
  
  def home_macro
    h.link_to 'Home', root_path
  end
  
  private
  
  def h
    ActionController::Base.helpers
  end

end

```


**note** you can do  `include UrlHelper` which includes `link_to` but this will work only for String based urls as this module was changed in Rails 4 ( [check source code](https://github.com/rails/rails/blob/3d9bd2ac9482eabf4ee0ed286952ccd19207e851/actionview/lib/action_view/helpers/url_helper.rb) ) 

if you keep getting error `arguments passed to url_for can't be handled ...` your only chance is to use my former code

### checkbox, radio input value to boolean

Rails 5, Rails 6, Rails 7

```ruby
ActiveRecord::Type::Boolean.new.cast "f"
```

in Rails 4.2 

```ruby
ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
```

in Rails 3.2 and down

```ruby
ActiveRecord::ConnectionAdapters::Column.value_to_boolean 'f'  # => false
ActiveRecord::ConnectionAdapters::Column.value_to_boolean 't'  # => true
ActiveRecord::ConnectionAdapters::Column.value_to_boolean '0'  # => false
ActiveRecord::ConnectionAdapters::Column.value_to_boolean '1'  # => true
ActiveRecord::ConnectionAdapters::Column.value_to_boolean nil  # => false
```


...works the same the only difference is that when `nil` is passed it
returns `nil` and `"y"`, `"n"` will give you deprication warning 

https://gist.github.com/equivalent/3825916

### Robots.txt examlpe

* http://tindeck.com/robots.txt
* http://www.ben-norman.co.uk/blog/seo/ten-examples-of-creative-robots-txt-files/


### Dont chache content that is restricted 

Tell browser not to cache content that hold harmfull data (e.g.: user settings, card details..>)

    <meta http-equiv="Cache-control" content="no-cache no-store">

### Memory stats simple method

```ruby
def memstats
  `ps -o size= #{$$}`.strip.to_i
end
```

source: ruby tapas 42


### grep tail 

```
 tail -f log/production.log | grep "NoMethodError"
```

### rails time to iso 8601 (javascript time)

```
"2010-10-25 23:48:46 UTC".to_time.iso8601
```

### Gems

* Moneta key store (good for caching) https://github.com/minad/moneta

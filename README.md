Scrapbook2
==============

Pure git/github version of my scrapbook on Ruby on Rails, web-development, linux system configuration.


    ##########################################################################
    ##                                                                      ##
    ##   Checke individual .md files above for more information on topics   ##
    ##                                                                      ##
    ##########################################################################
    
Archive: 
* Blogs are published on [http://www.eq8.eu/blogs](http://www.eq8.eu/blogs)
* Micro Blogs ar published on [http://ruby-on-rails-eq8.blogspot.com/](http://ruby-on-rails-eq8.blogspot.com/)


## Web-development notes unsorted

### checkbox, radio input value to boolean

```ruby
ActiveRecord::ConnectionAdapters::Column.value_to_boolean 'f'  # => false
ActiveRecord::ConnectionAdapters::Column.value_to_boolean 't'  # => true
ActiveRecord::ConnectionAdapters::Column.value_to_boolean '0'  # => false
ActiveRecord::ConnectionAdapters::Column.value_to_boolean '1'  # => true
ActiveRecord::ConnectionAdapters::Column.value_to_boolean nil  # => false

```

### Robots.txt examlpe

* http://tindeck.com/robots.txt
* http://www.ben-norman.co.uk/blog/seo/ten-examples-of-creative-robots-txt-files/


### Dont chache content that is restricted 

Tell browser not to cache content that hold harmfull data (e.g.: user settings, card details..>)

    <meta http-equiv="Cache-control" content="no-cache no-store">


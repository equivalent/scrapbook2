scrapbook2
==========

pure git/gitub version for my scrapbook around web-development

    ##########################################################################
    ##                                                                      ##
    ##   Checke individual .md files above for more information on topics   ##
    ##                                                                      ##
    ##########################################################################

# Ruby on Rails unsorted

### checkbox, radio input value to boolean

```ruby
ActiveRecord::ConnectionAdapters::Column.value_to_boolean 'f'  # => false
ActiveRecord::ConnectionAdapters::Column.value_to_boolean 't'  # => true
ActiveRecord::ConnectionAdapters::Column.value_to_boolean '0'  # => false
ActiveRecord::ConnectionAdapters::Column.value_to_boolean '1'  # => true
ActiveRecord::ConnectionAdapters::Column.value_to_boolean nil  # => false

```

# Other

### Robots.txt examlpe

* http://tindeck.com/robots.txt
* http://www.ben-norman.co.uk/blog/seo/ten-examples-of-creative-robots-txt-files/


# Security

### Dont chache content that is restricted 

Tell browser not to cache content that hold harmfull data (e.g.: user settings, card details..>)

    <meta http-equiv="Cache-control" content="no-cache no-store">


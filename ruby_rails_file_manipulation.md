# Pure ruby

**current folder**

```ruby
File.dirname(__FILE__)
#=> "."
```

**require files releted to current folder**

```ruby
# test/test_helper.rb
Dir[File.dirname(__FILE__)+"/support/**/*.rb"].each {|f| p  require f}   
#  => ["./test/support/upload_file_macros.rb"] 
```

# Rails

### root

     Rails.root.to_s
     
     

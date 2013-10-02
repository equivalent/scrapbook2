# Ruby only

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

**Remove all files inside directory**

    FileUtils.rm_rf(Dir.glob("./tmp/uploads/*"))

this will keep the `./tmp/uploads/` dir present, but will be empty

http://stackoverflow.com/questions/8538427/how-to-delete-all-contents-of-a-folder-with-ruby

# Rails

### root

     Rails.root.to_s
     
     

# pure Ruby

```
File.read(Pathname.new(File.dirname(__FILE__)).join('config', 'deploy.yml'))
```

### read file in chunks

```ruby
book = open('./whatever.txt')
lines = 0
while chunk = book.read(1024) # read chunk of 1024 Bytes
  lines += chunk.count("\n")
end
puts lines
```

###  detect if file exist in directory try 

```ruby
require 'pathname'
p = Pathname.new("app/views/")

p.ascend do |path|
  puts path
end

# app/view
# app

ascender = p.to_enum(:ascend)
ascender.detect { |path| (path + 'Rakefile').exist?}

```

good enum example

### absolute (root) path to gem folder

```ruby
ruby-1.9.2-p290 :001 > Gem.loaded_specs['awesome_engine'].full_gem_path
 => "/Users/younker/dev/engines/awesome_engine" 

ruby-1.9.2-p290 :002 > Gem.loaded_specs['rails'].full_gem_path
 => "/Users/younker/.rvm/gems/ruby-1.9.2-p290@foobar/gems/rails-3.1.3"
```

http://stackoverflow.com/questions/9743540/i-need-a-gems-full-path-from-inside-a-rails-app

### Load path

```ruby
 $LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
```

source: ruby tapas 051


### load modules

simply `load 'filename`

one interesting solution from backup gem is this :

```ruby
Dir[File.join(File.dirname(Config.config_file), "models", "*.rb")].each
do |model|
  instance_eval(File.read(model))
end
```
source: backup gem

### Home dir ruby 

```ruby
File.join(Dir.home, '.bashrc')
# => "/home/tomi/.bashrc"  

# ...this rely on home ENV.fetch('HOME') 
ENV.fetch('HOME')
# => "/home/tomi"

# You can explicitly specify user:
File.join(Dir.home('tomi'), '.bashrc')

# Or you can ask for current user
require 'etc'
user = Etc.getlogin             # => "tomi"
config_file = File.join(Dir.home(user), ".bashrc")
# => "/home/tomi/.bashrc"
```

source: ruby tapas 010

### Gem root dir

```ruby
# lib/my_gem.rb
module MyGem
  def self.root
    Pathname.new(File.expand_path '../..', __FILE__)
  end
end
```

### filename

```ruby
pathname = Pathname.new('foo/somefile.rb') 
# => #<Pathname:...>

pathname.to_s
# => 'foo/somefile.rb

pathname.basename.to_s
# => 'somefile.rb'

# get filename without extension
pathname.basename(".*").to_s
# => 'somefile'
```

this can be used to load child classes in same dir:

```ruby

# lib/application_strategy/foo.rb
module ApplicationStrategy
  class Foo
  end
end

# lib/application_strategy/bar_car.rb
module ApplicationStrategy
  class BarCar
  end
end

# lib/application_strategy/base.rb
module ApplicationStrategy
  class Base
  
    def self.strategies
      @strategies ||= begin
        Dir.glob("#{File.dirname(__FILE__)}/*")
          .collect { |file_path| Pathname.new(file_path).basename(".*").to_s }
          .select { |name| name != 'base' }
          .collect{ |name| "ApplicationStrategy::#{name.classify}".constantize } # classify & constantize are Rails methods
      end
    end 
    
  end
end

ApplicationStrategy::Base.strategies 
# => [ApplicationStrategy::Foo, ApplicationStrategy::BarCar]
```


### current folder

```ruby
File.dirname(__FILE__)
#=> "."
```

### require files releted to current folder

```ruby
# test/test_helper.rb
Dir[File.dirname(__FILE__)+"/support/**/*.rb"].each {|f| p  require f}   
#  => ["./test/support/upload_file_macros.rb"] 
```

### Remove all files inside directory

```ruby
require 'fileutils'
FileUtils.rm_rf 'foldername'
FileUtils.rm_rf(Dir.glob("./tmp/uploads/*"))
```
    
### Create dir 

~~~ruby
require 'fileutils' 
FileUtils.mkdir '/media/foldername'

Dir.mkdir "/media/myfolder", 0700
`sudo mkdir /media/myfolder`
~~~

### Directory exist ?

~~~ruby
File.directory?('path/to/something')
~~~

### Directory empty ?

```ruby
Dir["/media/myfolder/*"].empty?
```
    
### Rename files in path

    Dir.glob(folder_path + "/*").sort.each do |f|
      File.rename(f, folder_path + "/" + filename.capitalize + File.extname(f))
    end
    
This solution will keep the extension the way they were


### reading and writing to from file

~~~ruby

content =  normal_users.last.to_json

json_file =  File.open(target, "w") do |f|
  f.write(content)
end
json_file.close

~~~

or

~~~ruby

target = "#{Rails.root.to_s}/tmp/old_database_migration.json" 

data = ''
f = File.open(target, "r") 
f.each_line do |line|
  data += line
end
f.close

p data
~~~


this will keep the `./tmp/uploads/` dir present, but will be empty

http://stackoverflow.com/questions/8538427/how-to-delete-all-contents-of-a-folder-with-ruby

# Rails

### root

```ruby
Rails.root.to_s
```

### print all models

~~~ruby
Dir["#{Rails.root}/app/models/**/*.rb"].each {|file| print file }
~~~

or in rails 3 and 4 better solution is

```ruby
Rails.application.eager_load!
puts ActiveRecord::Base.descendants
```

### load/reload all models and decorators

```ruby
Dir["#{Rails.root}/app/models/**/*.rb", "#{Rails.root}/app/decorators/**/*.rb"].each { |file| load file }
Dir["#{Rails.root}/app/models/**/*.rb"].each { |file| load file }

```


### require specific file

```ruby
require Rails.root.join('lib', 'tld_constraint')
# equivalent of : require '/home/usr/my_rails_app/lib/tld_constraint'
```
     
     
### require all files in folder

```ruby
Dir[Rails.root.to_s + '/app/services/**/*.rb'].each {|file| require file }

# watch out, if it's for config, you can do in far simpler

module MyApp
  class Application < Rails::Application
    config.autoload_paths += %W(#{Rails.root}/app/models/concerns)
  end
end
```
     

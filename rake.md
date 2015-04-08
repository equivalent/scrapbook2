### enhancing existing rake task

... or how to call native Rails rake task plus my own task

```ruby
Rake::Task['db:create'].enhance do
  Rake::Task['db:my_task'].invoke
end
```

### rake prompt

... or console input 

```ruby

task :say_hi do
  puts "What's your name?"
  name = $stdin.gets.chomp
  puts "Hi #{name}!"
end
```

from https://gist.github.com/pixelmatrix/486467

### run execute other task from task

`    Rake::Task['db:schema:load'].invoke `

keywonds: invoke

### Show all rake tasks

    rake -T
    
* however this will print only tasks that have descrition(`desc`)

### Rake run rspec by default

```ruby
#Rakefile
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
```

if you need to override default Rails task

```
desc "this will be now a default task"
task info: :environment do
    puts 'Run rake test to test'
end

task(:default).clear.enhance ['info']
```

* sources: https://www.relishapp.com/rspec/rspec-core/docs/command-line/rake-task
* http://stackoverflow.com/questions/8112074/overriding-rails-default-rake-tasks
* published: october 2013 updated march 2015


### rake defaults

```ruby
namespace :foo do
  namespace :bar do
    task :car do
    end
  end
  task bar: "bar:car"
end

task default: "foo:bar"

```

### Use rails url/path helpers in rake task

```ruby
# lib/tasks/generate_page.rake
include Rails.application.routes.url_helpers
default_url_options[:host] = "myroutes.check"

namespace :page do
  task :generate => :environment do
    puts root_url
  end
end
```

for `rails 2.x` you have to include `include ActionController::UrlWriter`

alternativly you can use:

```ruby
p Rails.application.routes.url_helpers.posts_path
p Rails.application.routes.url_helpers.posts_url(:host => "example.com")
```

* source:  http://stackoverflow.com/questions/341143/can-rails-routing-helpers-i-e-mymodel-pathmodel-be-used-in-models
* Rails 3.2
* published: october 2013


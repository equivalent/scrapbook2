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

* sources: https://www.relishapp.com/rspec/rspec-core/docs/command-line/rake-task
* published: october 2013

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


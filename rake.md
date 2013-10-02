### Rake run rspec by default

```ruby
#Rakefile
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
```

https://www.relishapp.com/rspec/rspec-core/docs/command-line/rake-task

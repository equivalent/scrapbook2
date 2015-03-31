# Override default Rails rake task

```ruby
desc "this will be now a default task"
task info: :environment do
    puts 'Run rake test to test'
end

task(:default).clear.enhance(['info'])
```

source

* http://stackoverflow.com/questions/8112074/overriding-rails-default-rake-tasks
* http://blog.codingspree.net/2012/04/26/overwriting_rake_spec_task.html

```
bundle outdated  # list of outdated gems
bundle update    # update all gems
bundle update rails  #update rails gem
```

# install without test group

```ruby
#Gemfile

group :test do
  gem 'rspec' # ignored
end
```


```bash
bundle install --without test
```

# including tests in your gem 

## rspec

```ruby
# Rakefile
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
```


## Minitest

```ruby
# Rakefile
require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test

```


# creating own gem

### version

```ruby
#  lib/my_gem/version.rb
# encoding: utf-8

module MyGem
  module VERSION
    MAJOR = 0
    MINOR = 11
    PATCH = 1
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.');
  end
end
```

stolen from: https://github.com/peter-murach/github/blob/master/lib/github_api/version.rb


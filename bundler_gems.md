```
bundle outdated  # list of outdated gems
bundle update    # update all gems
bundle update rails  #update rails gem
```

# restore gem stete from cache

if you screw up `EDITOR=vim bundle open`

```
gem pristine gem name
```

# publish gems to rubygem

http://guides.rubygems.org/make-your-own-gem/#your-first-gem

```
gem build copy_carrierwave_file.gemspec
gem push copy_carrierwave_file-1.1.0.gem
```

# absolute path to gem folder

```ruby
ruby-1.9.2-p290 :001 > Gem.loaded_specs['awesome_engine'].full_gem_path
 => "/Users/younker/dev/engines/awesome_engine" 

ruby-1.9.2-p290 :002 > Gem.loaded_specs['rails'].full_gem_path
 => "/Users/younker/.rvm/gems/ruby-1.9.2-p290@foobar/gems/rails-3.1.3"
```

http://stackoverflow.com/questions/9743540/i-need-a-gems-full-path-from-inside-a-rails-app

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


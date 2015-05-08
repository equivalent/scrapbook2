# Use Rails (ActiveSupport) delegation class in plain ruby

```ruby
# Gemfile
source "https://rubygems.org"
gem 'active_support'
```

```ruby
require 'active_support/core_ext/module/delegation'

class Foo
  delegate :call, to: :other

  def other
    ->(){ 'foo' }
  end
end

Foo.new.call
# => 'foo'
```

source:
http://guides.rubyonrails.org/active_support_core_extensions.html#method-delegation`

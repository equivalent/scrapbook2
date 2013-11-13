# Ruby scrapbook




### Meta programing


#### Dynamic define class method

```ruby
module BreakCacheConcern
  def self.included(base)
    base.include ClassMethods
  end

  module ClassMethods
    def define_breakable_cache_method(method_name)
      instance_eval(
        "def #{method_name}
          return 'aaaa'
        end"
      )
    end
  end
end

class Foo
  include BreakCacheConcern
end

Foo.define_breakable_cache_method(:bar)
Foo.bar
```


# Rails Ruby object and core extensions

### try()

http://apidock.com/rails/Object/try

```ruby
a = nil
a.try(:[], 'a')   # nil
a = {'a'=> 'aaa'}
a['a']            # 'aaa'
a.try(:[], 'a')   # 'aaa'
```

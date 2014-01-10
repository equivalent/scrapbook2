# Ruby scrapbook


### make duplicate for hash tree

if you got `{foo: :bar}` then `{}.duplicate` is good enough

onece it comes to complicated hash

```ruby
hash_tree = {foo: {bar: :car}}
```

you have to do 

```
def deep_copy(o)
  Marshal.load(Marshal.dump(o))
end

new_hash = deep_copy(hash_tree)[:foo][:bar] = "taxi"

hash_tree[:foo][:bar] # => :car
new_hash[:foo][:bar]  # => "taxi"

``



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

#### currently executed method name

    __method__
    
#### argument names 

    def cool(dude, foo)
      p method(__method__).parameters.map { |arg| arg[1] }
    end
      
    cool   #=> [:dude, :foo]


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

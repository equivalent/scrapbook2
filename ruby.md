# Ruby scrapbook

### difference between `alias` and `alias_method`

`alias` is a keyword and it is lexically scoped. It means it treats self as the value of self at the time the source code was read . In contrast `alias_method` treats self as the value determined at the run time.

```ruby
class User
  def full_name
    puts "Johnnie Walker"
  end

  def self.add_rename
    alias_method :name, :full_name
  end
end

class Developer < User
  def full_name
    puts "Geeky geek"
  end
  add_rename
end

Developer.new.name #=> 'Gekky geek'

class User
  def full_name
    puts "Johnnie Walker"
  end

  def self.add_rename
    alias :name :full_name
  end
end

class Developer < User
  def full_name
    puts "Geeky geek"
  end
  add_rename
end

Developer.new.name #=> 'Johnnie Walker'

```



source:

http://blog.bigbinary.com/2012/01/08/alias-vs-alias-method.html

### undefine ruby constasnt / class

```
>> class Foo; end
=> nil
>> Object.constants.include?(:Foo)
=> true
>> Object.send(:remove_const, :Foo)
=> Foo
>> Object.constants.include?(:Foo)
=> false
>> Foo
NameError: uninitialized constant Foo
```

### executing sh in Ruby

...or Ways how to execute a shell script

http://stackoverflow.com/questions/2232/calling-bash-commands-from-ruby


Returns the result of the shell command to `value`

```ruby
value = `echo 'hi'`
value = `#{cmd}`
value = %x( cmd )
```

Return: true if the command was found and ran successfully, false otherwise

```ruby
wasGood = system( "echo 'hi'" )
wasGood = system( cmd )
```

Exits after execution

```ruby
exec( "echo 'hi'" )
exec( cmd ) # Note: this will never be reached beacuse of the line above
```

Note:

`$?`, which is the same as $CHILD_STATUS, accesses the status of the last system executed command if you use the backticks, `system()` or `%{}`. You can then access the exitstatus and pid properties

```ruby
$?.exitstatus
```

### reduce & inject

```ruby
[{aa: :foo}, {bar: :eee}].reduce(:merge)
# => {:aa=>:foo, :bar=>:eee} 
 
 # Sum some numbers
(5..10).reduce(:+)                             #=> 45
# Same using a block and inject
(5..10).inject { |sum, n| sum + n }            #=> 45
# Multiply some numbers
(5..10).reduce(1, :*)                          #=> 151200
# Same using a block
(5..10).inject(1) { |product, n| product * n } #=> 151200
```


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

```



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

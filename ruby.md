# Ruby scrapbook

### Ruby dynamic instance plugins from constants

```ruby
module Tea
  class Prepare
    def initialize(name)
      @name = name
      init_plugins
    end

    def init_plugins
      @plugins = []
      Plugins.constants.each do |name|
        @plugins << Plugins.const_get(name).new(self)
      end
    end

    def start
    end
  end

  module Plugins
    class AddMilk
      def initialize(tea_prepare)
        tea_prepare.extend(AddMilkToCup)
      end

      module AddMilkToCup
        def start(*)
          puts "Milk.."
          super
        end
      end
    end   
  end
end

Tea::Prepare.new('English breakfast tea').start
# "Milk"..
# => nil
```

source: ruby tapas 011

### replace string on multiple places

obviosuly this is easiest
```ruby
a = 'foo is so bar'
a.gsub(/foo/, 'bar')
a  # => 'bar is so bar'
```

```ruby
a ="foo is so foo"
# => "foo is so foo" 

a['foo'] = 'bar'
a  # => "bar is so foo" 

a['foo'] = 'bar'
a  # => "bar is so bar" 
```

however even better is to replace keys with sprintf hash value syntax 

```ruby
'%{foo} is so %{bar}' % {foo: 'moo', bar: 'car'}
# => "moo is so car"
```

### ruby literals

hexadecimal octal

```ruby
3.14          # this is literal as well
41            # ...even this 
1_000_000_000 # ...and this

a = 0b111101101  # this is binary literal
a.to_s(8)
#=> "755" 
a.to_s(16)
 => "1ed"

0755          # oct literal
0755.to_s(8) 
 => "755" 
0755.to_s(2)
 => "111101101" 

0x7fff     # hex literal

?c    #  this is literal as well
# => "c"

%w() # even this is literal

:foo             # => :foo
:"foo-#{123}"    # => :"foo-123"
```

source: ruby tapas 001 002 003 005

### ruby forwardable 

...or native ruby delagate / delegator


**delegate multiple attributes* 

```ruby
require 'forwardable'

class User

  attr_reader :account

  extend Forwardable

  def_delegators :account, :first_name, :last_name, :email_address
  # B.T.W.: this will work too 
  # def_delegators :@account, :first_name, :last_name, :email_address

  def initialize(account)
    @account = account
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end

GithubAccount = Struct.new(:uid, :email_address, :first_name, :last_name)
avdi = User.new(GithubAccount.new("avdi", "avdi@avdi.org", "Avdi", "Grimm")) 
avdi.full_name # => "Avdi Grimm"
```

**delegate one attribute* 

* this has an advantage that you can specify alias name (`:owner_email`)
* can use any object that evaluates as string for delegation
source even chain (`'@owner.account'`)

```ruby
require 'forwardable'

class Store
  extend Forwardable

  def_delegator '@owner.account', :email_address, :owner_email

  def initialize(owner)
    @owner = owner
  end
end

Account = Struct.new(:email_address)
Owner = Struct.new(:account)
owner = Owner.new(Account.new('foo@bar.com'))
store = Store.new(owner)
store.owner_email        # => "foo@bar.com" 
```

source: ruby tapas 006

### ruby prompt

...or console input

```ruby
require "highline/import"
input = ask "Input text: "
```

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

If you execute multiple arguments it's recommend to do it this way:

```ruby
source = '~/foo'
destination = '/tmp'
system *%W(cp -R #{source} #{destination}})
```

because when you run string (`system 'ls -a' `) ruby will pass the
command to shell (shell injection attacks, default shell may work
diferently), 

when you run list of args (`system 'ls', '-a'`) it forces execute of command directly


source: ruby tapas 005

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

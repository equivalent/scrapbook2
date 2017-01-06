# Ruby scrapbook

Topics not included/moved:

* Ruby Macros - look at `examples/macros_presented_in_rubytapas/README.md`
* StringIO
  * ruby tapas 29 (RubyTapas029-Redirecting-Output)
    * redirecting `puts` to do other stuff, or even system pipe puts
    * tags: `$stdout`, `$stderr`, `STDOUT`, `StringIO`, `IO.pipe`
* 


Topics:

## check for upcase in DB

```
 e = User.pluck(:email).select { |x| /[[:upper:]]/.match(x) } 
   (29.3ms)  SELECT "users"."email" FROM "users"
 => [] 

```

## apply lambda on variable


```
phone = "1(234)567-89-01"
lambda = -> { gsub(/[^0-9]/, '') }
phone.instance_exec &lambda
#=> "12345678901"
```

## Detecting if object is part of object space

```ruby
(ObjectSpace.each_object(Class).to_a - [Object, BasicObject]).
  detect{|c| c === ariel.widgets}
# => ActiveRecord::Associations::CollectionProxy
```

## execute something in dir

```ruby
# ~/app
Dir.chdir('~/diferent/project/') do
  `git pull origin master`
  `git add . `
  `git commit -m 'lazy bastard' `
  `git push origin master`
end
```



##  each_cons

```ruby
(1..9).each_cons(2) { |a| a } # nil

(1..9).each_cons(2).map { |a| a } # [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9]]

```

## lazy enum

```ruby

file = open('/usr/share/dict/words')

file
  .readlines  #read all 1000000 lines
  .first(100) # give me first 100

enum files
  .each_line    # enum
  .first(100)   # lazy read first 100 withotu reading all 1000000 in
                # first place


Prime.each do |n|
  puts n   # this will print prime numbers forever
end

# use only one at the time
enum = Prime.each  # enum
enum.next # => 2
enum.next # => 3


arry_of_squares = 1
  .step #  enum
  .first(4)  # [1,2,3,4]
  .map { |n| n**2 } # [1, 4, 9, 16]


squares = 1
  .step #  enum
  .lazy #  lazy enum <enum>
  .map { |n| n**2 } # lazy enum <lazy enum <enum>> 
                    # so this is "potential" to produce square numbers

arry_of_squares = squares.first(4) # [1, 4, 9, 16]

squares.each_slice  # Enum<enum<enum<enum>>>
squares.each_slice.first(4)  # array
squares.each_slice.take(4)   # Enum<enum<enum<enum<enum>>>>


# when using lazy, we crate a chanin of enumarators
# each enum has a link to the enum before 
```







## case 

```ruby
case 5
when (1..10)
  puts "case statements match inclusion in a range"
end

case "Hi there"
when String
  puts "case statements match class"
end

case "FOOBAR"
when /BAR$/
  puts "they can match regular expressions!"
end

case 40
when -> (n) { n.to_s == "40" }
  puts "lambdas!"
end




class Success
  def self.===(item)
    item.status >= 200 && item.status < 300
  end
end
 
class Empty
  def self.===(item)
    item.response_size == 0
  end
end
 
case http_response
when Empty
  puts "response was empty"
when Success
  puts "response was a success"
end
 
```

source: http://blog.honeybadger.io/rubys-case-statement-advanced-techniques/?utm_source=rubyweekly&utm_medium=email

## select elements of Array that occured multiple times

https://gist.github.com/equivalent/3c9a4c9d07fff79062a3
http://stackoverflow.com/questions/31342473/fetch-elements-that-occurred-multiple-times-in-ruby-array/31342580#31342580

```ruby
# fastest
[1,2,3,2,4,4,2,5]
  .group_by{ |e| e }
  .select { |k, v| v.size > 1 }
  .map(&:first)

#slow on large array but elegant
a = [1,2,3,2,4,4,2,5]
a.select{ |el| a.count(el) > 1 }.uniq
```

## get klass

```
Object.const_get('String')
```


## ruby convent integer to hex octal binary and other

```
 42.to_s(16)  # => 2a
 42.to_s(8)   # => 52
 42.to_s(2)   # => 101010
 42.to_s(36)  # => 16
```

convert to number from hex octal other

```
"2A".to_i(16)  # => 42
"101010".to_i(2)  # => 42

"2A".to_i(8)   # => 2 basically ignors A
"bullshit".to_i # => 0

# you should use
Integer("42")   # => 42
Integer("bullshit")   # =>  ArgumentError exception

Integer("101010", 2)   # => 42
Integer("2A", 8)       # => ArgumentError
Integer("2A", 16)      # => 42
```


## is class ancestor 

check blog 2015-04-23-ruby-ancestors-descendants-and-other-ways-how-to-pul-relatives.md

To be honest 

## Ruby String subscript assignment 


```ruby
str = "String Subscript Assignment"
str[0,0] = "107 " 
str                                   # => "107 String Subscript Assignment"
str[/^\d{3}/]                         # => "107"

str[/^(\d{3}) (.*)/] 
# => "107 String Subscript Assignment" 
str[/^(\d{3}) (.*)/, 1] 
# => "107" 
str[/^(\d{3}) (.*)/, 2] 
# => "String Subscript Assignment" 

str[/^(\d{3}) (.*)/, 2] = "How cool is that?" 
# => "How cool is that?" 
str
# => "107 How cool is that?" 

str[/^(?<number>\d{3}) (?<name>.*)/, :name] = "test
# test"  => "test test" 
 str
# => "107 test test" 
```

source: ruby-tapas 107


## Rebinding Methods

...prat of DCI (Domain, context and interaction )

```ruby
module DomainObject
  attr_accessor :role

  def play_role(role)
    self.role = role
    yield
  ensure
    self.role = nil
  end

  def method_missing(method_name, *args, &block)
    if role && role.public_method_defined?(method_name)
      role
        .instance_method(method_name)
        .bind(self)
        .call(*args, &block)
        # since ruby 2.0 methods of module can be
        # rebound to any object in the system
        # ( ruby 1.9. and lower required to bound
        # methods to same Class or ancestor) 
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_all = false)
    if role && public_method_defined?(method_name)
      true
    else
      super
    end
  end
end

class Account
  include DomainObject

  attr_reader :balance

  def initialize(balance)
    @balance = balance
  end

end

module TransferDestinationAccount
  def receive(amount)
    @balance += amount
  end
end

module TransferSourceAccount
  def transfer_to(destination, amount)
    destination.receive(amount)
    @balance -= amount
  end
end

savings_account = Account.new(50)
current_account = Account.new(400)

savings_account.play_role(TransferDestinationAccount) do
  current_account.play_role(TransferSourceAccount) do
    current_account.transfer_to(savings_account, 20)
  end
end

p savings_account.balance  # => 70
p current_account.balance  # => 380
p savings_account.class    # => Account
p current_account.class    # => Account
```

source: ruby-tapas 091


## csv to STDOUT (in console)

```ruby
require 'csv'
csv = CSV.new($stdout)

csv << ['foo', 'bar', 3]
# => foo,bar,3
```

## regular expresion literal

```ruby
%r(http://)  # => /http:\/\// # Regexp class

```

## current method name

```ruby
def foo
  __callee__
end

10.times do |i|
  define_method "a#{i}" do
    __callee__
  end
end

foo  # => :foo
a1   # => :a1
```

source: ruby tapas 064

## enumerator

```ruby
@foo = %w(test 1 2 3 end)

def foo
  @foo.size.times do
    p 'aaaaaaaaa'
    yield @foo.shift.to_sym
  end
end

my_enum = to_enum(:foo)
puts 'first call'
p my_enum.first(2)
p @foo

puts 'second call'
p my_enum.first(2)
p @foo

# first call
# "aaaaaaaaa"
# "aaaaaaaaa"
# [:test, :"1"]
# ["2", "3", "end"]
#
# second call
# "aaaaaaaaa"
# "aaaaaaaaa"
# [:"2", :"3"]
# ["end"]
```

* if you want to add more elements to `@foo` you should `my_enum.rewind` 
  but in ruby 2.x it seem it's not neccessary (not sure)

other useful tricks 

```ruby 
my_enum.detect{|n| n =~ /^B/}

my_enum.with_index do |name, index|
  puts "#{index}: #{name}"
end

my_enum.to_a  # => array of yielded values 
              # [:test, :"1", ...... :end]

```

to make enumerator return enum when no block given

```ruby
def names
  return to_enum(__callee__) unless block_given?
  yield 'foo'
  yield 'bar'
  yield 'car'
end

names.to_a #=> ['foo', 'bar', 'car']
names      # <Enumerator: main:names>
```
 

source: ruby tapas 059 064


## passing arguments to ruby console program

```ruby
ARGF.lines do |line|
 print  "#{ARGF.path}: #{line}"
end
```

now you can call

```bash
ruby my_scritp.rb document1.txt documet2.txt
ruby my_scritp.rb < document1.txt
```

@todo lines is depricated

source: ruby tapas 058

##  __FILE__ and $PROGRAM_NAME 

```ruby
__FILE__   # file that is really executed (current file)
$PROGRAM_NAME  # file through which we executing (if one file cals
               # another, then the first one file name)
$0 # same as $PROGRAM_NAME

# ...so you can do

if __FILE__ == $PROGRAM_NAME
  puts 'file is run as a script'
else 
  puts 'file runs as a part of higher hierarchy'
end
```

source: ruby tapas 055

## make Module method class method

```ruby
module Foo
  module_function # will make all methods availible
  # module_function :bar  # will just explicitly make bar
  
  def bar
    'bar'
  end
end

Bar.send :include, Foo

Foo.bar #=> 'bar'
Bar.new.send :bar  # => 'bar'
```

## to_s binary hex oct

```ruby
2.to_s(2)
# => "10" 

:foo.hash.to_s(16)
# => "4becf99b08344b"

:foo.hash.to_s(8)
#"1137317463302032113"
```

## memoize macro

```ruby
module Memoizable
  def memoize(method_name)
    original_method = instance_method(method_name)
    cache_ivar      = "@memoized_#{method_name}"
    define_method(method_name) do |*args, &block|
      cache = if instance_variable_defined?(cache_ivar)
                instance_variable_get(cache_ivar)
              else
                instance_variable_set(cache_ivar, {})
              end
      if cache.key?(args)
        return cache[args]
      else
        result = original_method.bind(self).call(*args, &block)
        cache[args] = result
        result
      end
    end
  end
end

class Foo
  extend Memoize

  def abc
    sleep 2
    123
  end

  memoize :abc
end

foo = Foo.new
foo.abc
foo.abc
```



## benchmark 

...or ruby speed

```ruby
require 'benchmark'
Benchmark.measure do
  'some-expensive-query'
end

Benchmark.bm do |bm|
  bm.report('1st call') { 'do something' }
  bm.report('2nd call') { 'do something else' }
end

#          user     system      total        real
#1st call  0.000000   0.000000   0.000000 (  0.000009)
#2nd call  0.000000   0.000000   0.000000 (  0.000010)

```

## execute external ruby script from ruby script

basically execute ruby file from another ruby file, e.g.: for smoke test

```ruby
require 'shellwords' # for shellsplit
require 'rake'   # it contains FileUtils::RUBY constant
                 # which is current ruby version (e.g. rvm)

FileUtils::RUBY
# => "/home/tomi/.rvm/rubies/ruby-2.1.1/bin/ruby" 

system "#{FileUtils::RUBY} ./tmp/test.rb".shellsplit
```

source: ruby tapas 047

## explicit or and one?


```ruby 
def replace_var(text, var_name, value=nil)
  unless block_given? ^ value  # one or other but not both
    raise ArgumentError,.
          "Either value or block must be given, but not both"
  end
  text.gsub!(/\{#{var_name}\}/) { value || yield }
end

# not all Classes suport ^ so you may need to convert them to boolean
# `!!44` 
```

if you need to compare  set of more than two use `one?` 

```ruby
[true, false, true].one?      # => false
[nil, false, 44].one?         # => true
[22, 44, 33].one?{|i| i.odd?} # => true
```

source: ruby tapas 043 044

## ruby scan 

... or better string match

```
# instead of : 
EMAIL_PATTERN = /\S+@\S+/i
addresses = []
while(match = EMAIL_PATTERN.match(text))
  addresses << match[0]
  text = match.post_match
end
addresses

# ..we can use
addresses = text.scan(EMAIL_PATTERN)

# ... or
text.scan(EMAIL_PATTERN) do |email|
  puts email
end

# ...or
EMAIL_PATTERN = /(\S+)@(\S+)/i
text.scan(EMAIL_PATTERN) do |name, domain|
  puts name
  puts domain
end
```

source: ruby tapas 41

....another way how to do regexp  is 

```
$1 if "Token 123".match(/Token\s+(.*)/)
# => '123'

$1 if "BAD".match(/Token\s+(.*)/)
# => nil

# but far better approch is to do 
headers['Authorization'].match(/Token\s+(.*)/) { |m| m[1] }
```


## ruby singleton objects

```ruby
class << (DEAD = Object.new)
  def to_s
    'X'
  end
end

DEAD.to_s # => 'X'
```

this is like `true` and `false`

difference to singleton Pattern that may be unsafe( Thred contation,
polifiration of dependancies) is that pattern restricts class so that
only one instnce object is ever created while singleton object are
statles.

```ruby
require 'singleton'
class Dead
  include Singleton
end

Dead.new # =>  # NoMethodError private method 
Dead.instance
 => #<Dead:0x000000024e5690> 
Dead.instance
 => #<Dead:0x000000024e5690>
```
ruby tapas 13, 07
  

## case when (switch)

switch is evaluating as threequal operator

```ruby
/\A\d+\z/ === '123'
(1..10) === 2

case obj
when /\A\d+\z/
  puts 'numeric string'
when 0..10
  puts 'positive integer'
when 123
  puts 'exactly 123'
```

procs/lambdas evaluates  threequals `===` as `#call` 
therefore when you pass lambda to switch:

```ruby
require 'net/http'
SUCCESS = -> (response) { (200..299) === response.code.to_i }
CLIENT_ERROR = -> (response) { (400..499) === response.code.to_i }

response = Net::HTTP.get_response(URI.parse('http://google.com'))


case response
when SUCCESS then puts 'Success!'
when CLIENT_ERROR then puts 'Client error.'
else puts 'Other'
end
```

source: ruby tapas 37

## symbol coverted to  a proc

```ruby
:foo.to_proc 

# ...will translate to somehing like this:

->(receiver, *args) do
  receiver.send(:foo, *args)
end

# ...usage:

:foo.to_proc
  .call(Struct.new(:foo).new(2))   # => 2
```

source: ruby tapas 35

## raise rescue ensure

```ruby
DEFAULT_FALLBACK = ->(error) { raise }

def testing(&fallback)
  fallback ||= DEFAULT_FALLBACK

  begin
    p 'aaa'
    raise 'some error'
  resuce Bar
    puts 'when bar error'
  rescue => error
    fallback.call(error)
  ensure 
    p 'bbb'
  end
end

testing
# "aaa"
# "bbb"
# RuntimeError "some error"

testing do |error|
  puts "Error was triggered: #{error}"
end
# "aaa"
# Error was triggered: some error
# "bbb"
```

## Ruby C lib

check `FFI` gem
ruby tapas 026

## Tempfile

```ruby
require 'tempfile'

Tempfile.open('foobar' ) do |foo|
  # file location /tmp/fooo20140625-7872-c4e4pv>
  foo.write 'abc'
  foo.close
  foo.read # => 'abc'
end
```

source: ruby tapas 023

### simple JSON request example

```ruby
require 'net/http'

require 'rubygems'
require 'json'

@user = 'user@socialtext.com'
@pass = 'password'
@host = 'pitchblende.socialtext.net'
@port = '22222'

@post_ws = "/data/workspaces"

@payload ={
    "name" => "api-workspace",
    "title" => "API Workspace",
    "account_id" => "1"
  }.to_json
  
def post
     req = Net::HTTP::Post.new(@post_ws, initheader = {'Content-Type' =>'application/json'})
          req.basic_auth @user, @pass
          req.body = @payload
          response = Net::HTTP.new(@host, @port).start {|http| http.request(req) }
           puts "Response #{response.code} #{response.message}:
          #{response.body}"
        end

thepost = post
puts thepost
```

source: 
* https://www.socialtext.net/open/very_simple_rest_in_ruby_part_3_post_to_create_a_new_workspace
* http://www.rubyinside.com/nethttp-cheat-sheet-2940.html

### ERB 

```ruby
require 'erb'

title = 123
description = 'foo bar'

template = ERB.new(<<EOF)
  <dc:title><%= title %></dc:title>
  <dc:description><%= description %></dc:description>
EOF

template.result(binding)
```

source: ruby tapas 023

### list of all  required paths

apply for both Rails & pure Ruby

```ruby
$:     # => ["/home/user/.rvm/rubies/ruby-2.1.1/lib/ruby/gems/2.1.0/gems/json-1.8.1/lib", ...]

# you can add
$: << 'test'
```

source: peepcode pwhang

### convert exception to return value

ruby stores reference of currently raised exception to `$!` variable
```ruby
value_or_error = {}.fetch(:mo) rescue $!
value_or_error       # => <#KeyError: key not found :mo>
value_or_error.class #=> KeyError
```

source: ruby tapas 022

### Struct & OpenStruct

```ruby
Point = Struct.new(:x, :y)
Point.new                       # => #<struct Point x=nil, y=nil>
Point.new(23)                   # => #<struct Point x=23, y=nil>

a = Point.new(5,7) 
a.members                       # => [5,7]   # list all attributes
a.map { |x| x * 2 }             # => [10, 14]
```

```ruby
require 'ostruct'
a = OpenStruct.new(a: 1, b: 2)
a.a # => 1
a.c = 3
a.c # => 3

```

source: ruby tapas 020 025

### #bind

```ruby
class Foo
  def send(*args)
    raise "mu-he-he"
  end
end

class Bar < Foo
  def send(*args)
    puts 'I\'m sending'
    super
  end
end

Bar.new.send(:inspect)
# I'm sending
# RuntimeError: mu-he-he

class Car < Foo
  def send(*args, &block)
    puts 'I\'m sending correctly :)'
    original_send = Object.instance_method(:send)  # unbound method object
    bound_send = original_send.bind(self)          # bound it to object
    bound_send.call(*args, &block)                 # call method obj
  end
end

Car.new.send :inspect
# puts 'I\'m sending correctly :)'
# => "#<Car:0x00000002fcefc0>" 
```

source: ruby tapas 016

### #super

disable block

```ruby
class Child < Parent
  def hello(subject=:default)
    if subject == :default
      super(&nil).
      puts "How are you today?"
    else
      super(subject, &nil)
      puts "How are you today?"
    end
  end
end
```

if super is defined

```ruby
module YeOlde
  def hello(subject="World")
    if defined?(super)
      super
    else
      puts "Good morrow, #{subject}!" 
    end
    puts "Well met indeed!"
  end
end
```
source: ruby tapas 014 016

### hash 

#### #fetch 

```ruby
example = {b: 'bb'}

example.fetch(:a)
# => KeyError: key not found:

example.fetch(:a) { |key| raise "Woooot ? key #{key} was not found" }
# RuntimeError: Woooot ? key a was not found

def foo
  sleep 2
  10
end

example.fetch(:a) { foo }
# sleep 2 seconds
# => 10 

example.fetch(:b) { foo }
# => 'bb' # without sleep 


# difference between `[:key]` and fetch(:key)

{}[:foo] || :default             # => :default
{foo: nil}[:foo] || :default     # => :default
{foo: false}[:foo] || :default   # => :default  

{}.fetch(:foo){:default}             # => :default                              
{foo: nil}.fetch(:foo){:default}     # => nil
{foo: false}.fetch(:foo){:default}   # => false

```

you can do same magic for Array

```ruby
[:a, :b].fetch(1) { something }
```

#### hash default values

```ruby
stock_count = Hash.new do |hash, missing_key|
  # this hash is run only when key is missing from hash
  hash[missing_key] = 0
end

stock_count.fetch('vodka') # => KeyError missing key

stock_count['vodka'] =+ 1  
stock_count['vodka'] # => 1



config = Hash.new do |h,k|
  h[k] = Hash.new(&h.default_proc)
end

config[:production][:database][:adapter] = 'mysql'
config[:production][:database][:adapter] # => "mysql"

```

source = ruby tapas 032



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

# is stuff defined in ruby  and rails

##how to detect if constant or module class is defined in app

    Object.const_defined?(:CachedAt)

##how to detect if method is defined

    object.defined?(:method)


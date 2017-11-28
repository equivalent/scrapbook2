# Ruby `#call` method

In Ruby programming Language there is well know feature called Lambda
(and Proc), that acts as an executable chunk of code that can be
passed and may be executed outside of its definition via `#call`


```ruby
my_lambda = ->(name, phone){ puts "Hi #{name} your phone-number is #{phone}" }
my_lambda.call('Tomas', '555-012-123')

# Hi Tomas your phone-number is 555-012-123
```

Now the true value of Lambdas is  they get passed around as command
objects without polluting your business object with logic that is not a object
concern. For example if you have to print/log something from within an
object yet you don't see a reason why that object should be responsible
for holding print/log logic implementation:


```ruby
class User
  attr_accessor :name
  attr_reader :contacts, :logger

  def initialize(logger: ->(n, p) { } )
    @contacts = []
    @logger = logger
  end

  def add_contact(phone)
    logger.call(name, phone)
    contacts << phone
  end
end


user_without_log = User.new
user_without_log.name = "Zdenka"
user_without_log.add_contact("555-012-123")
# no output to log


my_custom_logger = ->(name, phone){ puts "User #{name} added phone number #{phone} to his/her profile" }
user_with_log = User.new(logger: my_custom_logger)
user_with_log.name = "Zdenka"
user_with_log.add_contact("555-012-123")
# User Zdenka added phone number 555-012-123 to his/her profile


user_without_log.contacts
# => ["555-012-123"]
user_with_log.contacts
# => ["555-012-123"]
```


This code is also really easy to test thanks to lambda:

```ruby
require `spec_helper`
RSpec.describe User do
  # ...
  describe 'logging' do
    it do
      @was_called_with = nil
      user = User.new(logger: ->(n, p) { @was_called_with = {name: n, phone: p })
      user.name = 'Foo'
      user.add_contact(123)

      expect(@was_called_with).to eq({name: 'Foo', phone: 123})
    end
  end
end
```

But this article is not about lambdas but about `#call` method. So let
me show you something else

Imagine that your logger is in a different object  (e.g. `MyFramework#log` method)


```ruby
class MyFramework
  def log(*args)
    puts("Logger received: #{args.join(', ')}")
  end
end

my_framework = MyFramework.new
my_framework.log('Hello World', 'whatever', 'foo')
Logger received: Hello World, whatever, foo
```

How would you pass it to logger ?

Well most simplest solution would be just create new lambda right?

```ruby
my_framework = MyFramework.new

user_with_framework_logger = User.new(logger: ->(*args){ my_framework.log(*args)})
user_with_framework_logger.name = "Ruby"
user_with_framework_logger.add_contact("555-012-123")
# Logger received: Ruby, 555-012-123
```

Wow ! That's an ugly code

Ruby has a way how to convert methods to Method objects with
[method](https://apidock.com/ruby/Object/method) and more secure
[public_method](https://apidock.com/ruby/Object/public_method). This
method object can be then passed and called within other object:

```ruby
my_framework = MyFramework.new
method_logger = my_framework.public_method(:log)
method_logger.call('Escape', 'the', 'faith')
# Logger received: Escape, the, faith

user_with_framework_logger = User.new(logger: method_logger)
user_with_framework_logger.name = "Oli Sykes"
user_with_framework_logger.add_contact("555-012-123")
# Logger received: Oli Sykes, 555-012-123
```

Same apply to class methods

```ruby
module MyClassMethodBasedFramework
  def self.log(*args)
    puts("Derp received: #{args.join(', ')}")
  end
end

my_logger = MyClassMethodBasedFramework.public_method(:log)
my_logger.call('August', 'burns', 'red')
# Derp received: August, burns, red

user_with_framework_logger = User.new(logger: my_logger)
user_with_framework_logger.name = "Atrey"
user_with_framework_logger.add_contact("555-012-123")
# Derp received: Atrey, 555-012-123
```

> I bet there was a time when some senior Ruby dude was trying to sell
> you on Ruby with sentence: "Ruby is awesome because everything is an Object".
> Yes, he probably was showing you that a String is an object not just a
> type. But literally in Ruby nearly everything is an object! Methods
> are objects, Class is an object, ...think about it.


Now imagine that this generic logger is to simple and you want to pass a
custom class object. Well all you need to do is ensure the object
contains *common interface* method `#call`

```ruby
class MyComplexCustomLogger
  attr_reader :program_name

  def initialize
    @program_name = $PROGRAM_NAME # Ruby built in var
  end

  def call(name, phone)
     puts "#{program_name} has logged: User #{name} added #{phone}"
  end
end


custom_logger = MyComplexCustomLogger.new
custom_logger.call('Charlie', '555-1234')
# irb has logged: User Charlie added 555-1234

user_with_custom_logger = User.new(logger: custom_logger)
user_with_custom_logger.name = "Helia"
user_with_custom_logger.add_contact("555-012-123")
# irb has logged: User Helia added 555-012-123
```



So I hope I showed you something new and cool about Ruby. But the point
of the article is to highlight the iportance of `#call`

Lot of time Ruby developers write single responsibility classes/objects
with single run method named `#run` or `#execute`:

```ruby
Person = Struct.new(:year)
tomas = Person.new
tomas.year = 1988

class TellMeYourAge
  def initialize(person)
    @person = person
  end

  def calculate_age
    Time.now.year - @person.year
  end
end

TellMeYourAge.new(tomas).calculate_age
# => 29

class RemoveOldDevelopersFromDB
  def initialize(list)
    @list = list
  end

  def run
    @list.delete_if { |x| x.year < 1990 }
  end
end

list = [tomas]
RemoveOldDevelopersFromDB.new(list).run
list
# => []
```

And I get it there are cases when you want to describe the object
behavior with the name of interface method. `RemoveOldDevelopersFromDB`
clearly does execution of command to remove items from DB. Therefore
`#run` method kinda make sense.

> You can learn about Command Query Separation and why it's important
> [here](https://martinfowler.com/bliki/CommandQuerySeparation.html)

The name of the single responsibility class is usually descriptive
enough so honestly the object would not lose this "description" if we just named the common interface
method `#call`:

```ruby
class TellMeYourAge
  def initialize(person)
    @person = person
  end

  def call
    Time.now.year - @person.year
  end
end

TellMeYourAge.new(tomas).call
# => 29

class RemoveOldDevelopersFromDB
  def initialize(list)
    @list = list
  end

  def call
    @list.delete_if { |x| x.year < 1990 }
  end
end

list = [tomas]
RemoveOldDevelopersFromDB.new(list).call
list
# => []
```

Plus this way we automatically enable our objects to be able to be
passed to other objects:

```
Puppy = Struct.new(:age)
max = Puppy.new
max.age = 3

everyone = []
everyone << TellMeYourAge.new(tomas)
everyone << max.public_method(:age)

everyone.map(&:call).sum
#=> 32
```


Call is everywhere in Ruby.

```ruby
:age.to_proc.cal(max)
# => 3
```

And it's considered a common interface method name for small single responsibility
class objects.


> This article is heavily inspired by Avdi Grimm's Ruby Tapas episode
> [callable](https://www.rubytapas.com/2012/12/12/episode--callable/).
> I recommend to check it out for further information.

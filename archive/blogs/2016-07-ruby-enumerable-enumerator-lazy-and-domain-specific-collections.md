# Ruby Enumerable, Enumerator, Lazy and domain specific collection objects

> Entire source code can be found here: https://gist.github.com/equivalent/70d82d228ca957b21a4d968353f367b8 ([mirror](https://github.com/equivalent/scrapbook2/blob/master/archive/blogs_gist/enumerables_enumerators_and_lazynes.rb))

In this article I'm trying to explain Ruby Eumerator, Lazy Enumerator and Enumerable
module but mainly show some examples how to implement them in a real Application
in order to get collection objects that maps your domain.

The article is bit too long but I'm trying to squeeze in lot of
information on a topic that is hard to explain with few sentences. The
 goal was to write an Article I wish I had several years ago as a
Ruby beginner, but also article that I wish I had not too long
ago when implementing complex API mapping to domain logic. Esencially I
want this article to be a singe entry I could point any Ruby developer when I'm
asked about this topic in the future.

## Enumerator basics

Before I'll get to the juicy part first lets remind ourself what are Enumerators.
The easiest way to show this is to convert Array to Enumerator:

```ruby
my_array = [1,2,3]
e = my_array.to_enum
# => #<Enumerator: [1, 2, 3]:each>

# list of availible methods:
e.public_methods(false)
# => [:each, :each_with_index, :each_with_object, :with_index, :with_object, :next_values, :peek_values, :next, :peek, :feed, :rewind, :inspect, :size]
```

So, as you can see Enumerator is an Object on which you can call methods
like `#each` and `#size` but interesting ones for us are `#next_values` and
`#rewind`:

```ruby
e.next_values
# => [1]

e.next_values
# => [2]

e.next_values
# => [3]

e.next_values
# StopIteration: iteration reached an end
# from (irb):20:in `next_values'
# from (irb):20
```

We reached the end of Enumerator ! Lets rewind:

```ruby
e.rewind

e.next_values
# => [1]

# ... and so on
```

Similar can be done with Hash:

```ruby
my_hash = {a: 'a', b: 'b'}
# => {:a=>"a", :b=>"b"}

eh = my_hash.to_enum
# => #<Enumerator: {:a=>"a", :b=>"b"}:each>

eh.next_values
# => [[:a, "a"]]

eh.next_values
# => [[:b, "b"]]

# ...
```

But in the end the real value for us is the ability to loop through the
elements with `#each` method

```ruby
e.each do |member|
  puts member
end
# 1
# 2
# 3

eh.each do |key, value|
  puts "#{key.inspect} is #{value.inspect}"
end
# :a is "a"
# :b is "b"
```

But guess what. Result of `#each` is an Enumerator !

```ruby
[].each
# => #<Enumerator: []:each>

{}.each
# => #<Enumerator: {}:each>
```

So we could say that Enumerator is an object that you can iterate
through and it remembers a state of the next value, therefore objects like Array,
Hash uses Enumerator to do it's iterations.

> Ruby Arrays are really complex topic for another article. In reality
> Ruby uses `C` lang Array behind the scene for some operations. For rest of the article think
> about Array purely the Enumerator way.

I've read lot of complicated Enumerator articles explaining how they work,
but I  didn't quite understand them till I've seen this plain Ruby object example:

```ruby
class Bar
  def each
    yield 'xxx'
    yield 'yyy'
    yield 'zzz'
  end
end

bar = Bar.new
# => #<Bar:0x00000001f2f160>

bar.each do |member|
  puts member
end
# xxx
# yyy
# zzz
```

So we could say that the secret of iteration in Ruby is really the `yield`.

> Avdi Grim in several of his [Ruby Tapas](http://www.rubytapas.com/) screencasts
> done some really detailed look
> on Ruby Enumerable and Enumerator. Definitely recommending to
> subscribe to it. Some of his insights I'm forwarding
> in this article.

## Enumerable

My definition of `Enumerable` is that it's a core Ruby module
that lets you extend your objects with common Array-alike methods that
are building their functionality around object `#each` implementation.

...well that sentence sounds horrible, here is an example:

```ruby
class Foo
  include Enumerable

  def each
    yield 'aaa'
    yield 'bbb'
    yield 'ccc'
  end
end

foo = Foo.new

foo.each do |member|
  puts member
end
# aaa
# bbb
# ccc

foo.count
# => 3

foo.to_a
# => ["aaa", "bbb", "ccc"]

foo.map(&:capitalize)
# => ["Aaa", "Bbb", "Ccc"]

foo.max
# => "ccc"

foo_enumerator = foo.to_enum

foo_enumerator.next_values
# => ["aaa"]
foo_enumerator.next_values
# => ["bbb"]
# ...
```

> Too see list of all methods provided via `Enumerable` do
> `foo.public_methods`

## Simple Enumerable colection class mapping your domain

So far nothing valuable, lets do some real life
usage example, and by real-life I mean I'll demonstrate actual
production code that is actually out there somewhere.

Basic story is that we had a plain Ruby object `Membership` that was
holding some data collected via microservice API call.

```ruby
class Membership
  attr_accessor :type, :owner

  def free?
    type == 'free'
  end

  def paid?
    type == 'paid'
  end

  def unassigned?
    owner.nil?
  end

  # purely for debugging purpose
  def to_s
    "I'm a Membership type=#{type} and I'm #{unassigned? ? 'unassigned' : 'assigned'}"
  end
  alias inspect to_s
end
```

We were doing several operations with the collection of `Membership` objects so We've decided to
create collection object `MembershipCollection`:

```ruby
class MembershipCollection
  include Enumerable

  def initialize(*members)
    @members = members.flatten
  end

  def each(*args, &block)
    @members.each(*args, &block)
  end

  def free
    select { |m| m.free? }
  end

  def paid
    select { |m| m.paid? }
  end

  def unassigned
    select { |m| m.unassigned? }
  end
end
```

> In this version of `MembershiCollection` I'm just delegating the `#each` method to `@members`
> which is an Array and returning it's Enumerator implementation.
> This is just me being lazy  and we will refactor it soon!
> But really this is ok, we don't need anything fancy right now.

So This way we would be able to call:

```ruby
m = Membership.new

m.free?
# => false

m.paid?
# => false

MembershipCollection.new(m).free.to_a  # == []
MembershipCollection.new(m).paid.to_a  # == []

# assign Membership 'free' state:
m.type = 'free'

m.free?
# => true

m.paid?
#=> false

MembershipCollection.new(m).free.to_a  # == [m]
MembershipCollection.new(m).paid.to_a  # == []

# assign Membership 'paid' state:
m.type = 'paid'

m.free?
# => false

m.paid?
# => true

MembershipCollection.new(m).free.to_a  # == []
MembershipCollection.new(m).paid.to_a  # == [m]
```

Well this is nice but all the heavy lifting is done by `#select` really and the problem with `#select` is that it will return an `Array` therefore you wont be able to do chaining like:

```ruby
mfu = Membership.new.tap { |m| m.type = 'free', m.owner = nil }
mfa = Membership.new.tap { |m| m.type = 'free', m.owner = 123 }
mpa = Membership.new.tap { |m| m.type = 'paid' }

collection = Membership::MembershipCollection.new(mfu, mfa, mpa)
collection.free.unassigend  # wont work !!!
# NoMethodError: undefined method `unassigned' for Array
```

One way how to fix this is to initialize same collection class on colected results:

```ruby
class MembershipCollection
  # ...

  def free
    self.class.new(select { |m| m.free? })
  end

  def paid
    self.class.new(select { |m| m.paid? })
  end

  def unassigned
    self.class.new(select { |m| m.unassigned? })
  end
end
```

So code the chaining code example will work now this way:

```ruby
collection.to_a
# => ["I'm a Membership type=free and I'm unassigned",
      "I'm a Membership type=free and I'm assigned",
      "I'm a Membership type=paid and I'm unassigned"]

collection.free.to_a
# => ["I'm a Membership type=free and I'm unassigned", "I'm a Membership type=free and I'm assigned"]

collection.free.unassigned
# => ["I'm a Membership type=free and I'm unassigned"]
```

This works due to the fact that

```ruby
collection.free.class
# => Membership::MembershipCollection

collection.free.unassigned.class
# => Membership::MembershipCollection
```

This example is good for small scope collections where you expect that
anything can call anything. It's similar to Rails `where` scope like e.g.:
`where(id: [1,2]).where(my_flag: true)` is the same thing as in reversed
order `where(my_flag: true).where(id: [1,2])`.

## Custom Enumerator collection classes mapping domain logic

Imagine a scenario that you're writing collection classes in which only
certin collection can call another particular collection.

For example business requirements are that only `free` memberships can
be `unassigned` like:

```ruby
membershisps.free.unassigned # => [....]
```

...but this should never be called for `paid` memberships
 or maybe they should return results based on completly different
criteria!

```ruby
membershisps.paid.unassigned # NoMethodError !

# ...or

membershisps.paid.unassigned # diferent logic than  memberships.free.unassigned
```

So one way how to deal with this is to define custom collection classes
for every scope and alter their implementation of `#each` method with
condition:

```ruby
module MembershipCollectionV3
  module Base
    def self.included(base)
      base.send :attr_reader, :members
      base.include Enumerable
    end

    def initialize(*members)
      @members = members.flatten
    end
  end

  class Free
    include Base

    def each
      @members.each { |m| yield m if m.free? }
    end

    def unassigned
      Unassigned.new(to_a)
    end
  end

  class Paid
    include Base

    def each
      @members.each { |m| yield m if m.paid? }
    end
  end

  class Unassigned
    include Base

    def each
      @members.each { |m|  yield m if m.unassigned? }
    end
  end
end
```

```ruby
mfu = Membership.new.tap { |m| m.type = 'free', m.owner = nil }
mfa = Membership.new.tap { |m| m.type = 'free', m.owner = 123 }
mpa = Membership.new.tap { |m| m.type = 'paid' }

free_collection = MembershipCollectionV3::Free.new(mfu,mfa,mpa)
puts free_collection.members.inspect
# => [I'm a Membership type=free and I'm unassigned, I'm a Membership type=free and I'm assigned, I'm a Membership type=paid and I'm unassigned]

puts free_collection.to_a.inspect
# => [I'm a Membership type=free and I'm unassigned, I'm a Membership type=free and I'm assigned]

puts free_collection.unassigned.to_a.inspect
# => [I'm a Membership type=free and I'm unassigned]

puts paid_collection.to_a.inspect
# => [I'm a Membership type=free and I'm unassigned]

puts paid_collection.unassigned
# undefined method `unassigned' for #<MembershipCollectionV3::Paid:0x0000000281d4e8> (NoMethodError)
```

This closely maps our business needs. It may seems like an
overkill but trust me the benefits are sweet when it comes to
larger API mapping or API that change too often as you can move objects
more easily.

If you are mapping a small amount of possibilities in collection, then you may
not need this approach.

Everything so far may seem cool to a Enumerator newcomer,
but any Senior Ruby dude reading this article
will not be impressed. You see solutions so far
works with finite set of data passed to evaluation.

This may work for an API or database where you get back 100 records all the time, but
what if you just want to call API until you get exactly 5 records that
match your criteria. You don't want to make 100 call and after first 5
discover that's all you need just to make 5 calls, just because your
collection classes are expecting 100 records. (well this is a stupid
example. There are other ways how to handle this, but it kinda brings the case up)

## Lazy Enumerator

Before I get to the implementation in our `MembershipCollection` Let me first
explain what is Lazy Enumerator.

Our **regular Enumerator** works from left to right, meaning that every
other part of the chain (part to the right) is called only after
evaluation of the former part of the chain (part on the left), like
this:

```ruby
puts (1..10).to_a.inspect
# => [1,2,3,4,5,6,7,8,9]

(1..10).select {|x| x.odd?}.inspect
# => [1,2,3,4,5,6,7,8,9] => [1, 3, 5, 7, 9]

puts (1..10).select {|x| x.odd?}.select{|y| y > 5 }.inspect
# => [1,2,3,4,5,6,7,8,9] => [1, 3, 5, 7, 9]  => [7, 9]

```
What's really happening is: `1..10 -> to_a -> select -> select`.

On the other hand **Lazy Enumerator** works from right to left, meaning
that we will build up something like super enumerator that will
individually valuate each value individually trough out the entire chain.

```ruby
puts (1..10).lazy.inspect
# => #<Enumerator::Lazy: 1..10>

puts (1..10).lazy.select {|x| x.odd?}.inspect
# #<Enumerator::Lazy: #<Enumerator::Lazy: 1..10>:select>

puts (1..10).lazy.select {|x| x.odd?}.select{|y| y > 5 }.inspect
#<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator::Lazy: 1..10>:select>:select>

puts (1..10).lazy.select {|x| x.odd?}.select{|y| y > 5 }.to_a.inspect
# 1 => 1 => nope
# 2 => nope
# 3 => 3 => nope
# 4 => nope
# 5 => 5 => nope
# 6 => nope
# 7 => 7 => 7 => [7]
# 8 => nope
# 9 => 9 => 9 => [7,9]
# 10 => nope
#
# end result => [7,9]
```

What's really happening: `1..10 <- select <- select <- first(5)`

Therefore we are able to do this only amount of time we need
**without worrying we would consume all the memory**:

```ruby
(1..Float::INFINITY).lazy.select {|x| x.odd?}.select{|y| y > 5 }.first(8).inspect
# => [7, 9, 11, 13, 15, 17, 19, 21]
```

> Be careful `#to_a`, `#first(5)` will force Lazy enumerator to
> evaluate. If you trying to initialize enumerator that takes 5 elements of enumeration
> without forcing evaluation use `#take(5)`.

I'm hoping that this gave you some overview how Lazy Enumerator work. I
wont go into more details as this article is way over limit, plus there
are already good articles that covers this topic:

* http://ruby-doc.org/core-2.0.0/Enumerator/Lazy.html#method-i-lazy
* https://www.sitepoint.com/implementing-lazy-enumerables-in-ruby/
* http://patshaughnessy.net/2013/4/3/ruby-2-0-works-hard-so-you-can-be-lazy

## Domain specific collection object respecting Lazynes

Till this point we were trying to make our collection implement our own way
of `#each` and use Enumerable module to build common Array-alike
interface around it.

But we were ignoring the fact that enumerator is object of it's own
right too. We can pass it to our collection and delegate other methods to it.

> More on this topic from different angle http://blog.arkency.com/2014/01/ruby-to-enum-for-enumerator/

Whether you agree or disagree, my opinion is that object composition is the most
cleanest and most flexible form of communication between objects and this is exactly
how we going to make our collection objects to have both
Lazy Enumerator capabilities and standard Enumerator capabilities.

```ruby
require 'forwardable' # core Ruby lib.

module MembershipCollectionV4
  module Base
    extend Forwardable
    def_delegators :each, :first, :to_a, :map

    def self.included(base)
      base.send :attr_reader, :enum
    end

    def initialize(enum)
      @enum = enum
    end
  end

  class Constructor
    include Base

    def each
      enum.map do |raw_m|
        puts "0000 !!!" # our sophisticated debugging
        Membership
          .new
          .tap { |m| m.type  = raw_m.fetch(:type) }
          .tap { |m| m.owner = raw_m.fetch(:owner) }
      end
    end

    def free
      Free.new(each)
    end
  end

  class Free
    include Base

    def each
      enum.select do |m|
        puts "AAAAA !!!" # our sophisticated debugging
        m.free?
      end
    end

    def unassigned
      Unassigned.new(each)
    end
  end

  class Unassigned
    include Base

    def each
      enum.select do |m|
        puts "BBBBB !!!" # our sophisticated debugging
        m if m.unassigned?
      end
    end
  end
end
```

As you can see initialization method is expecting Enumerator
object and we are delegating methods like `#first`, `#to_a`, `#map` to it.

In order to show the difference between Lazy and regular Enumerator I'm
printing some text to output.

Now imagine that we are receiving data via an API Gateway that is
similar to this:

```ruby
data = [
  { type: 'paid', owner: nil },
  { type: 'paid', owner: nil },
  { type: 'free', owner: 123 },
  { type: 'paid', owner: nil },
  { type: 'free', owner: 456 },
  { type: 'free', owner: nil },
  { type: 'free', owner: 678 },
  { type: 'free', owner: nil },
  { type: 'paid', owner: nil },
]
```

We have now options to initialize our collection class with old fashion
Enumerator:

```ruby
enumerator = data.to_enum
# => #<Enumerator: [{:type=>"free", :owner=>123}, .....]:each>

unassigned_1 =  MembershipCollectionV4::Constructor.new(enumerator).free.unassigned
result = unassigned_1.first(2)
# 0000 !!!
# 0000 !!!
# 0000 !!!
# 0000 !!!
# 0000 !!!
# 0000 !!!
# 0000 !!!
# 0000 !!!
# 0000 !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# BBBBB !!!
# BBBBB !!!
# BBBBB !!!
# BBBBB !!!
# BBBBB !!!

puts result
# I'm a Membership type=free and I'm unassigned
# I'm a Membership type=free and I'm unassigned
```

Or we can pass in Lazy Enumerator:

```ruby
lazy_enum = data.lazy  # API stream from socket connection, or dictionary with 10_000_000 lines
# => #<Enumerator::Lazy: [{:type=>"free", :owner=>123}, {:type=>"free", :owner=>nil}, {:type=>"paid", :owner=>nil}]> 

unassigned_2 =  MembershipCollectionV4::Constructor.new(lazy_enum).free.unassigned
result = unassigned_2.first(2)
# 0000 !!!
# AAAAA !!!
# 0000 !!!
# AAAAA !!!
# 0000 !!!
# AAAAA !!!
# BBBBB !!!
# 0000 !!!
# AAAAA !!!
# 0000 !!!
# AAAAA !!!
# BBBBB !!!
# 0000 !!!
# AAAAA !!!
# BBBBB !!!
# 0000 !!!
# AAAAA !!!
# BBBBB !!!
# 0000 !!!
# AAAAA !!!
# BBBBB !!!

puts result
# I'm a Membership type=free and I'm unassigned
# I'm a Membership type=free and I'm unassigned
```

As you can see results are the same only the output of our
"sophisticated debugging" is different. It's the same logic as we were
explaining before:

* Regular Enumerator evaluates all values on every
layer and passes those that meet criteria to next Enumerator layer.
*  Lazy Enumerator tries to evaluates one value through out all layers of
Enumerators one at a time unless it not meet condition of any of layers.

Now this way of writing collection classes gives you flexibility of
changing your decisions in a future with least amount of change.

When to use Enumerator and when Lazy it's really up to you to decide.
Benchmark tools and common sense are your best friend. I just wanted to show you
tools now go build some pyramids!

## Sources

* [Enumerator](http://ruby-doc.org/core-2.2.0/Enumerator.html)
* [Eneumerable module](http://api.rubyonrails.org/v4.2/classes/Enumerable.html)
* [Lazy Enumerator](http://ruby-doc.org/core-2.0.0/Enumerator/Lazy.html#method-i-lazy)
* [Ruby Tapas](http://www.rubytapas.com/) screencasts

## Related

* [Extending Enumerable so it comply with Rails](https://gist.github.com/equivalent/9a97dff5a8a24bf84868d913a512add7)
* unfinished article on [Enumerable to comply with Rails conventions](https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/2016-07-rails-and-enumerable.md) - not finished

# Ruby Ancestors, Descendants and other annoying relatives


> Updates:
> * 2015-04-24 23:22 Update 1: adding "Inherited hook" solution, recommended way how to do this

(Spoiler alert, using StarWars plot to describe behavior)

Let say you have an inheritance:

```ruby
class DarthVader
end

class Luke < DarthVader
end

class Leia < DarthVader
end
```

...and you want to pull some Ancestor information from classes

```ruby
Luke.superclass        # => DarthVader
DarthVader.superclass  # => Object

Luke.ancestors         # => [Luke, DarthVader, Object, Kernel, BasicObject]
DarthVader.ancestors   # => [DarthVader, Object, Kernel, BasicObject]

# compare
Luke <= DarthVader  # true
Luke <= Object      # true
Luke <= Leia        # nil
DarthVader <= Luke  # false
```

> (So we finaly know who is [Darth Vader's father](http://scifi.stackexchange.com/questions/1630/who-is-anakin-skywalkers-father))

But how would you pull "Descendats" (children classes) from parent class (`DarthVader`) ?

Well turns out in our Ruby world the StarWars plot is in **reverse**
Luke knows that Darth Vader is his father but Darth Vader has no clue.

This logically make sence. Class `Luke` knows about existance of `DarthVader`
but class `DarthVader` is just a class on it's own.

Here is a little UML to demonstrate this

```ruby
# ____________      ________
# |DarthVader|   <- | Luke |
# ------------      --------
#                   ________
#                <- | Lea  |
#                   --------
```

> This is really good example of no mather how much you try, your
> application is always different than the real life. Ruby objects only
> **represent** real life.
>
> Think about a married couple in a divorce where each of them is
> represented by a lawyer. These two lawyers are married in real life.
> The lawyer couple not neceseraly need to be in a divorce themself to
> represent their clients.
>
> (Lawyer example stolen from Robert C. Martin)

So there is no "bulit in" way how to just call `DarthVader.descendants`
but you can build one:

```ruby
class Parent
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end

class Child < Parent
end

class GrandChild < Child
end

Parent.descendants => [Child, GrandChild]

Child.descendants = [GrandChild]
```

(stolen from http://stackoverflow.com/questions/2393697/look-up-all-descendants-of-a-class-in-ruby)

...however that could be bit slow if you have too many clases
as you are looping through all Objects in ObjectSpace
(discussion [here](https://www.ruby-forum.com/topic/193281))

> When you think about it, it's like DarthVader taking DNA test with
> everyone in the known universe, not even knowing if he have any
> children in the first place.

Benchmarking on my machin was not that bad:

```ruby
require 'benchmark'
Benchmark.bm do |bm|
  bm.report('1st call') { Parent.descendants }
  bm.report('2nd call') { Parent.descendants }
end
```

Benchmark on plain Ruby project (irb):

```bash
          user     system      total        real
1st call  0.010000   0.000000   0.010000 (  0.011786)
2nd call  0.010000   0.000000   0.010000 (  0.004776)
```

Benchmark on medium size production Rails project that I work on currently:

```bash
          user       system      total        real
1st call  0.030000   0.000000   0.030000 (  0.034386)
2nd call  0.020000   0.000000   0.020000 (  0.013391)
```


If this is too slow for you, you may want to cache this into a instance variable:

```ruby
class Parent
  def self.descendants
    @descendants ||= ObjectSpace.each_object(Class).select { |klass| klass < self }
  end
end
```

Benchmark on medium size production Rails project that I work on currently:

```bash
          user     system      total        real
1st call  0.030000   0.010000   0.040000 (  0.033732)
2nd call  0.000000   0.000000   0.000000 (  0.000003)
```

...but if you need to have a fresh list of moduls each time you run this method
then this solution just feels wrong.

There are some other ways how to accomplish the same thing but all are bit messy.

But we are Ruby developers lets think about another way how to do this.

## Module namespace to save the day

Depening what are the business rules we may want to just scope in
namespace the related Classes:

```ruby
module DarthVader
  class Luke
  end

  class Lea
  end
end
```

Here you can do:

```ruby
DarthVader::Luke.ancestors
# => [DarthVader::Luke, Object, Kernel, BasicObject]

DarthVader.constants
# => [:Luke, :Lea]

DarthVader
  .constants
  .map { |const_symbol| DarthVader.const_get(class_symbol) }
# => [DarthVader::Luke, DarthVader::Lea]
```

> You still have a wierd situation wher Luke kinda knows about DarthVader
> beeing his father, so there will be no drama in cinema, but you can
> finally pull the children from `DarthVader`.

Just watch out `.constants` will pull all classes in namespace:

```ruby
module DarthVader
  module DarkForce
  end

  BlowUpDeathStar = Class.new(StandardError)

  class Luke
  end

  class Lea
  end
end
```

...will give you:

```ruby
DarthVader.constants  # => [:DarkForce, :BlowUpDeathStar, :Luke, :Lea]
```

So you may want to filter out the values you don't want:

```ruby
DarthVader
  .constants
  .map { |class_symbol| DarthVader.const_get(class_symbol) }
  .select { |c| !c.ancestors.include?(StandardError) && c.class != Module }
  # => [DarthVader::Luke, DarthVader::Lea]
```

> You don't have to blacklist all classes you don't like.
> The filter can be anything related to your domain. For example
> `.select { |c| c.resopond_to?(:ligtsaber) }`

Now you are like: "A ha! I still need to do some wierd filtering !"
Well yes, but you are pulling classes only from `DarthVader` namespace and
filtering it against `DarthVader` module, not against the entire `ObjectSpace`

Here are the benchmarks:

```ruby
module DarthVader
  DarkForce = Module.new
  BlowUpDeathStar = Class.new(StandardError)
  Luke = Class.new
  Lea = Class.new

  def self.descendants
    DarthVader
      .constants
      .map { |class_symbol| DarthVader.const_get(class_symbol) }
      .select { |c| !c.ancestors.include?(StandardError) && c.class != Module }
  end
end

require 'benchmark'
Benchmark.bm do |bm|
  bm.report('1st call') { DarthVader.descendants }
  bm.report('2nd call') { DarthVader.descendants }
end
```

Benchmark on medium size production Rails project that I work on currently:

```
       user     system      total        real
1st call  0.000000   0.000000   0.000000 (  0.000083)
2nd call  0.000000   0.000000   0.000000 (  0.000039)
```

## Class namespance and inheritance

If you are in a situation that you have to inherit from `DarthVader` think
about this solution:

```ruby
class DarthVader
  def self.descendants
    DarthVader
      .constants
      .map { |class_symbol| DarthVader.const_get(class_symbol) }
  end

  class Luke < DarthVader
    # ...
  end

  class Lea < DarthVader
    # ...
  end

  def force
    'May the Force be with you'
  end
end
```

Benchmark on medium size production Rails project that I work on currently:

```bash
           user     system      total        real
1st call  0.000000   0.000000   0.000000 (  0.000050)
2nd call  0.000000   0.000000   0.000000 (  0.000027)
```

...and you can now do:

```ruby
DarthVader.new.force
# => "May the Force be with you"

DarthVader::Luke.new.force
# => "May the Force be with you"
```

------------

**UPDATE 1:**

## Using the `inherited` hook

As Jim Gay ([SaturnFlyer](http://www.saturnflyer.com/)) kindly pointed out in his [comment bellow](http://www.eq8.eu/blogs/13-ruby-ancestors-descendants-and-other-annoying-relatives#comment-1984880528) and Steve Jorgensen in his [reddit post](http://www.reddit.com/r/ruby/comments/33naj7/ruby_ancestors_descendants_and_other_annoying/) there is even better solution:

```ruby
class DarthVader
  def self.inherited(klass)
    @descendants ||= []
    @descendants << klass
  end

  def self.descendants
    @descendants || []
  end
end

class Luke < DarthVader
end

DarthVader.descendants  # => [Luke]
```

I don't really have to benchmark it as this solution is registering classes once they inherit parent class therefore is the fastest one. I'm recomending this approach as you will avoid silly cases where you both inherit and namespace the same Class.

Thank you Jim

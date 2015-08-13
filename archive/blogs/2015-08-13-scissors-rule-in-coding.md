# Scissors Rule in coding

The other day I was trying to google some articles on **Scissors Rule**
so I could explain it in my [StackOwerflow comment][1] but I found out
there is no google search result `:)`.

I first learned about Scissors Rule from [Robet C. Martin][3] in his
screencasts [Clean Coder][2].

The rule is from **old days** where programers where styling the code in a
way that public methods / interface methods were at the top of the code
and private methods were at the bottom. So if you theoretically print the
source code of a file and you can cut it with scissors in half. This
way you will end up with list of public methods so that other programers / developers can implement them in their code.

### Does it have to be at top ?

User TurquoiseTurkey in a [Reddit Discussion][6] on this toppic had really good point:

> I always put the public functions at the bottom of the file and the static
> ones at the top, so I don't have to use forward declarations.

The rule is not about placing them only at the top, but having them in one place
(Top or Bottom whatever is the best practice in your language) so that other
developers implement your code much easily and they don't end up
jumping around the file to find all public interface methods.

One more thing I want to point out to avoid confusion:

*The rule is not about placing public methods on the very top / bottom of a file
Nope it's just about not mixing public and private methods.*

Here is an example from [Ruby Style Guide][7] on the topic: "how to organize Ruby
classes":

```ruby
class Person
  # extend and include mixins
  extend SomeModule
  include AnotherModule

  # inner classes
  CustomErrorKlass = Class.new(StandardError)

  # constants
  SOME_CONSTANT = 20

  # attribute macros
  attr_reader :name

  # other macros
  validates :name

  # public class methods
  def self.some_method
  end

  # initialization goes between class methods and other instance methods
  def initialize
  end

  # followed by other public instance methods
  def some_method
  end

  # protected and private methods are grouped near the end
  protected

  def some_protected_method
  end

  private

  def some_private_method
  end
end
```

As you can see class has many different declarations before the public
interface starts, yet this still comply with scissor rule.

### How much useful is it these days ?

Well depend on what's your opinion on `private` methods in general.
Are you using them ? Are you trying to
clearly point out to other developers which are the "stable" `public`
interface methods and which are the "unstable" `private` methods that
are target of functionality change.

I'm a Ruby developer that is trying to comply with Clean Coder principles
(meaning I respect public / private separation) so for me scissor rule is a good guide.

Plus, Ruby has this in place by default (not sure if that was intention doh):

```ruby
class Foo
  attr_reader :number

  def initialize(number)
    @number = number
  end

  def call
    do_some_stuff
    do_some_other_stuff
  end

  private

  def do_some_stuff
    @number = number + 100
  end

  def do_some_other_stuff
    @number = number + 50
  end
end

foo = Foo.new(2)
foo.public_methods(false)     # => [:number, :call]
foo.number                    # => 2
foo.call
foo.number                    # => 152
```

Ruby on Rails framework best practices goes even further and recommend to
add extra level of indentation bellow private, so that developer
browsing the code clearly notice that the context of methods changed

```ruby
class Foo
  attr_reader :number

  def initialize(number)
    @number = number
  end

  def call
    do_some_stuff
    do_some_other_stuff
  end

  private
    def do_some_stuff
      @number = number + 100
    end

    def do_some_other_stuff
      @number = number + 50
    end
end
```

So the scissors rule is already in place for Ruby developers. And to be
honest it's not that bad idea. The code is more readable.

That's why I'm always trying to fallow it when I'm using other languages.

I wouldn't call this "rule" a rule but more a recommendation. Sometimes you
need to do stuff that will break this convention. But in general if you
have two ways how to do same piece of functional code, with same
performance and same readability but one is not fallowing the scissors
rule and other is, I would go with the one that comply with the rule `:)`

### private vs public

If you want to learn more about why `public` -  `private` is important
I'm recommending you to read [Practical Object-Oriented Design in
Ruby][4] by [Sandi Metz][5] or watch formerly mentioned [Clean Coders
Screencasts][2] (from what I remember first two or three episodes
are talking about importance of the well structured code)

But the main point is that your public methods suppose to be the "stable
methods" that you won't change that often (e.g. change arguments), so
that other developers can relly on your class. Private methods are the
one you can go nuts in refatroring, change attributes, add functionality,
improving benchmarks and so on.

The scissors rule just adds a cherry on top of it by making the class
clear enough visually. So you won't end up doing something like this:


```ruby

class Foo
  attr_reader :number

  def initialize(number)
    @number = number
  end

  def call
    do_some_stuff
    do_some_other_stuff
  end

  def do_some_stuff
    @number = number + 100
  end
  private :do_some_stuff

  def do_some_other_stuff
    @number = number + 50
  end
  private :do_some_other_stuff

  def diffeent_call
    something_different
  end

  def something_different
  end

  private :something_different
end

Foo.new(2).public_methods(false)  #=> [:number, :call, :diffeent_call]
```

### Context indented methods

Reddit user `mirhagk` responded to [the discussion][6] with this point:

> For myself I tend to structure most classes with related methods
> together, even if one is public and the other is private

I seen this before (again in Clean Coders screencasts) where the
developer done same thing plus he actually indented methods depending
on the level of calling.

For example if you have `public_method` calling `private_method_1` and
that is calling `private_method_2`

For example the abbove example could be written like this:

```ruby

class Foo
  attr_reader :number
  private :do_some_other_stuff, :do_some_stuff, :something_different, :something_more_different

  def initialize(number)
    @number = number
  end

  def call
    do_some_stuff
    do_some_other_stuff
  end

    def do_some_stuff
      @number = number + 100
    end

    def do_some_other_stuff
      @number = number + 50
    end

  def diffeent_call
    something_different
    # ...
  end

    def something_different
      something_more_different
      # ...
    end

      def something_more_different
        # ...
      end
end
```

And it's a really good point and I fully agree that this is good approach in some languages,
specially if you writing something in functional programing style.

It's realy about the Language you are using and how flexible it's syntax
is.

*I personally don't recommend it in Ruby as it's killing Ruby's elegance.*

But if you really want to write the code this way maybe combine both rules.
Write public methods to top and indent private methods to their context.

```ruby
class Foo
  attr_reader :number

  def initialize(number)
    @number = number
  end

  def call
    do_some_stuff
    do_some_other_stuff
  end

  def diffeent_call
    something_different
  end

  private
    def do_some_stuff
      # ...
    end

    def do_some_other_stuff
      # ...
    end

    def something_different
      something_more_different
      # ...
    end

      def something_more_different
        something_more_more_different
        # ...
      end

        def something_more_more_different
          # ...
        end
end
```

If you have this code in any Object Oriented Language in 90% of casses you
missed an abstration, meaning that the class has too many responsibilities
and therefore some parts shoud be extracted to a different classes or the class should be
actually two separate classes:

```ruby
class FooStuff
  attr_reader :number

  def initialize(number)
    @number = number
  end

  def call
    do_some_stuff
    do_some_other_stuff
  end

  private
    def do_some_stuff
      # ...
    end

    def do_some_other_stuff
      # ...
    end
end

class FooDifferentStuff
  attr_reader :number

  def initialize(number)
    @number = number
  end

  def call
    something_more_different
    # ..
  end

  private
    def something_different
      something_more_different
      # ...
    end

    def something_more_different
      something_more_more_different
      # ...
    end

    def something_more_more_different
      # ...
    end
end
```

### Discussion and Sources

Thank you to all that joined the discussion on Reddit and reminded me of
all the stuff I forgot to mention in the article.

* https://www.reddit.com/r/ruby/comments/3gu51u/scissors_rule_in_coding_put_your_public_methods/
* https://www.reddit.com/r/programming/comments/3gu1sc/scissors_rule_in_coding_put_your_public_methods/

[1]: http://stackoverflow.com/a/31983564/473040
[2]: https://cleancoders.com/
[3]: http://www.objectmentor.com/omTeam/martin_r.html
[4]: http://www.poodr.com/
[5]: http://www.sandimetz.com/
[6]: https://www.reddit.com/r/programming/comments/3gu1sc/scissors_rule_in_coding_put_your_public_methods/
[7]: https://github.com/bbatsov/ruby-style-guide#classes--modules

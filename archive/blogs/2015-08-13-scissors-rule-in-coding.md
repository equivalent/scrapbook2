# Scissors Rule in coding

The other day I was trying to google some articles on **Scissors Rule**
so I could explain it in my [StackOwerflow comment][1] but I found out
there is no google search result `:)`.

I first learned about Scissors Rule from [Robet C. Martin][3] in his
screencasts [Clean Coder][2].

The rule is from old days where programers where styling the code in a
way that public methods / interface methods were at the top of the code
and private methods were at the bottom. So if you theoretically print the
source code of a file and you can cut it with scissors in half. This
way you will end up with list of public methods so that other programers / developers can implement them in their code.

User TurquoiseTurkey in a [Reddit Discussion][6] on this toppic had really good point:

> I always put the public functions at the bottom of the file and the static
> ones at the top, so I don't have to use forward declarations.

The rule is not about placing them only at the top, but having them in one place
(Top or Bottom whatever is the best practice in your language) so that other
developers implement your code much easily and they don't end up
jumping around the file to find all public interface methods.

How much useful is it these days ? Well depend on what's your opinion
on `private` methods in general. Are you using them ? Are you trying to
clearly point out to other developers which are the "stable" `public`
interface methods and which are the "unstable" `private` methods that
are target of functionality change.

I'm a Ruby developer and a follower of Clean Coder principles so for me
scissor rule is "good to know" rule. Plus, Ruby has this rule by
default (not sure if that was intention doh):

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

I wouldn't call this rule a rule but more a recommendation. Sometimes you
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

### Discussion and Sources

Thank you to all that joint the discussion on Redit and reminded me of
some more stuff I didn't mentioned.

* https://www.reddit.com/r/ruby/comments/3gu51u/scissors_rule_in_coding_put_your_public_methods/
* https://www.reddit.com/r/programming/comments/3gu1sc/scissors_rule_in_coding_put_your_public_methods/

[1]: http://stackoverflow.com/a/31983564/473040
[2]: https://cleancoders.com/
[3]: http://www.objectmentor.com/omTeam/martin_r.html
[4]: http://www.poodr.com/
[5]: http://www.sandimetz.com/
[6]: https://www.reddit.com/r/programming/comments/3gu1sc/scissors_rule_in_coding_put_your_public_methods/

# Lesson learned after trying Elixir (as a Ruby developer)

I'm a Ruby developer since early 2010 and big fan of Object Oriented
Programming (OOP) always extending my knowledge around it and I'm not planing to end that any day soon.
But as a part of this growth it's required to play around with new
ideas and see whey they take you.

Recent years there is quite a rumble around functional programming
languages especially due to fact that Moore's law may reach it's peak
pretty soon.

> Moors law is a prediction that power of CPU will double every 1.5
> year. That's why future of computer power will be about increasing the number of CPU cores
> rather than pushing single CPU core to the limit. One day we may have
> 128 CPU cores in our laptops, but biggest problem is that everyone still writes software for a
> single core CPU, so 127 CPU cores wasted.

> But I'm not planing to talk about how to do Multithread in Ruby I just want
> to bring some background why state is such different concept with
> functional programming

You see OOP languages are all about state + behavior. Account knows how to
withdraw money but also has a balance:

```ruby
class Account
  attr_accessor :balance

  def withdraw(amount)
    self.balance = self.balance - amount
  end
end

my_account = Account.new
my_account.balance = 40
my_account.withdraw(9)
my_account.balance
# => 31
```

Now this is straightforward example for single core without any issue.

But if you had in your memory 5000 `Account.new` objects and you would
want to process them with `Account#withdraw` in all our 128 cores then
and then do some calculation on how much money left your Bank
all together you need to plan how you synchronize  your objects "state" in different threads.

> Plus there is an annoying fact that in MRI Ruby you can have many threads running concurrently with MRI,
> but only one thread will ever be running at any moment in time.
> I'm not going to explain why as there are already good
> resources out there (e.g.: [Fluentz - parallelism with Ruby](https://blog.fluentz.io/learn-how-to-achieve-parallelism-with-ruby-i-o-bound-threads-a29c92aff58c))

Now functional programming languages clearly separate the "behavior" and
the "state". In fact the state is trying to be "immutable" = non changing.

There is no such thing as an instance variable, or objects. There are
just values and functions. Functions modify values to create new values
but they never modify the state.

> This way synchronizing of state with Functional Programming
> Language is much easier in multi core environment.

Here is the same example written in [Elixir](https://elixir-lang.org) (a functional programming
language)

```elixir
defmodule AccountOperations do
  def withdraw(balance, amount) do
    balance - amount
  end
end

balance = 40
new_balance = AccountOperations.withdraw(balance, 9)
# => 31
```

Here is the same example written in  Ruby lang in functional fashion:

```ruby
module AccountOperations
  extend self

  def withdraw(balance, amount)
    balance - amount
  end
end


balance = 40
new_balance = AccountOperations.withdraw(balance, 9)
# => 31
```

Look how straight forward this piece of code is.
You pass "state", "modifier state" and result is new state.

And that's it. The most important lesson I've learned form Elixir is
this way of coding some bids of modification logic.

![](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2017/rly.jpg)

You may be asking is this really all?

Well there is more to it. Let's dive do Rails example:

### Backgroud worker example

Ruby on Rails since 4.2 has a common way how to schedule background jobs
(like DelayedJob, Sidekiq, Rescue) called
[ActiveJob](http://guides.rubyonrails.org/v4.2.0/active_job_basics.html)

You just create a file in `app/jobs/do_my_task.rb`:

```ruby
class DoMyTask < ActiveJob::Base
  queue :high

  def perform(document_id:)
    # ...
  end
end
```

And schedule it like this:

```ruby
document = Document.create(title: 'foo')
DoMyTask.perform_now(document_id: document.id)    # perform now
DoMyTask.perform_later(document_id: document.id)  # schedule BG worker to process it later
```

The reason why we are passing `document_id` instead of `document` object  is because to scheduled jobs we want to
give the most primitive data that we need to recover the information. In
this case just the integer `id` of the `Document` so we can retrieve it
from the database:

```ruby
class DoMyTask < ActiveJob::Base
  # ...

  def perform(document_id:)
    document = Document.find_by(id: document_id)
    if document.title == 'foo'
      # do some lot of processing
      # on lot of lines
    else
      # do some different processing
      # on lot of lines
    end
  end
end
```

Now imagine that our code got way out of hand for a single method and we
want to extract the data to smaller methods within the Job file (or
maybe even schedule other Jobs).

There are two ways to pass the `document` object around.

One is way is to pass the object as a function argument:


```ruby
class DoMyTask < ActiveJob::Base
  # ...

  def perform(document_id:)
    document = Document.find_by(id: document_id)

    if document.title == 'foo'
      data_processing(document: document)
    else
      notify_admin_of_incorrect_file(document: document)
    end
  end

  private
    def data_processing(document:)
      # ...
      a_result = data_processing_a(document: document)
      data_processing_b(document: document, a_result: a_result)
    end

    def data_processing_a(document:)
      document.do_something
      # ...
    end

    def data_processing_b(document:, a_result: )
      document.do_somethnig_else(a_result)
      # ...
    end

    def notify_admin_of_incorrect_file(document:)
      UserMailer.notify_admin(title: document.title).deliver_now
    end
end
```

The other way is to set instance variables and continue calling it as our Job object state:


```ruby
class DoMyTask < ActiveJob::Base
  # ...

  def perform(document_id:)
    @document = Document.find_by(id: document_id)

    if document.title == 'foo'
      data_processing
    else
      notify_admin_of_incorrect_file
    end
  end

  private
    def data_processing
      a_result = data_processing_a
      data_processing_b(a_result)
    end

    def data_processing_a
      @document.do_something
      # ...
    end

    def data_processing_b(a_result)
      @document.do_somethnig_else(a_result)
      # ...
    end

    def notify_admin_of_incorrect_file
      UserMailer.notify_admin(title: @document.title).deliver_now
    end
end
```

The first more functional way is pretty much doing what is should do. It
just executes what we are expecting from the Job by passing the object
to other smaller methods as an argument.

> And before we go too deep this is how it should be done

One may say second approach is doing the same thing.
But I would argue it's doing one important extra thing. It sets the
state of the object.

So what? It's more Object oriented and that's a good thing right ?

Well not really. What is the name of the method we are executing again?
It's `#perform` not `#set_document_and_perform`.

This may not be an issue in a Job object like this as we know it will
ever do one thing. But this coding approach creates a really bad habit:
Mixing multiple responsibilities for methods.


Imagine this scenario:

```
class Invoice < ActiveRecord::Base
  attr_accessor :user

  def process_data(user)
    @user = user
    extract_address
    # ..
  end

  def can_delete?
    user.is_admin?
  end

  private
    def extract_address
      self.invoice_address = "#{@user.country}, #{@user.city}"
      self.save
    end
end


invoice = Invoice.last
invoice.user = moderator_without_delete_permission
invoice.can_delete?
# => false
invoice.process_data(admin_user)
invoice.can_delete?
# => true
```

There are many things that are wrong with this example like the fact
that this piece of logic should go to different object. But the core
point I want to demonstrate here is that we introduced a security bug thanks to introduction of
state that is not part of responsibility of the object.

Developer who implemented `process_data` method and uses the `@user`
instance variable is not aware of another developer introduced
`attr_accessor :user` (which sets and reads `@user` internally) for security checking.

Now when we try to process an invoice of a Admin user, regular moderator
will suddenly have delete permission by end of the execution. Now yes
this is hypothetical issue that would be probably discovered thanks to
code reviews but the point is that it doesn't ever have to be concern if it was
written more "functional" way:

```ruby
class Invoice < ActiveRecord::Base
  def process_data(user:)
    extract_address(user)
    # ..
  end

  def can_delete?(user:)
    user.is_admin?
  end

  private
    def extract_address(user)
      self.invoice_address = "#{user.country}, #{user.city}"
      self.save
    end
end


invoice = Invoice.last
invoice.can_delete?(user: moderator_without_delete_permission)
# => false
invoice.process_data(user: admin_user)
invoice.can_delete?(user: moderator_without_delete_permission)
# => false
```

> *"What the hell are talking about, it's still object oriented code and
> not functional !"*
>
> Yes, we are still working with object User, but the code behind
> `#can_delete?` and `#process_data` is written in functional way.
>
> When I say "functional way" I don't mean abolish all object and state.
> Just keep it where it's relevant.

Another example would be if the data was co


### Conclusion

My favorite quote from functional programming proponents is:

**State is root of all evil**

Now for some developers that may sound like overkill but I can
definitely relate to that claim. I've seen developers setting class
level variables in Puma environment that would override each other under 
parallel runs, I've seen developers serialize objects, change state in
database and then send email with  the deserialized object data, ...

![I've seen things you people wouldn't belive](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2017/i-ve-seen-things.jpg)

In some of the cases developers were lazy and set the state just to save
3 line of code change, in some cases developers went over board
expressing themself of how OOP they can be.


Now don't get me wrong there are definitely proper ways how you can
design your objects and your application without ever having this
problems but that won't happen over night.

> If you really serious about OOP then my Top 4 resources from top of my head are:
>
> * read [Sandi Metz book](https://www.sandimetz.com/products/)  **Practical Object-Oriented Design in Ruby**
> * watch [David West OOP is Dead! Long Live OODD!](https://www.youtube.com/watch?v=RdE-d_EhzmA)
> * watch  screencasts by Avdi Grimm [Ruby Tapas](https://www.rubytapas.com)
> * watch screencasts by Robert C. Martin [Clean Coders](https://cleancoders.com/videos)


OOP is more than just Object + State. It's also about patterns, design &
developer discipline. If you are a team of well established OOP Gurus then
you don't necessary need this article. Write me a comment on how wrong I
am and you are fine.

But if you are a small workshop
trying to make the best of what you can and then one day because you
need to release new feature you quickly hire random
contractor that will destroy your well maintained objects then you are
far better of with stateless way of passing objects (more functional
way)

Again this article is not enough it probably creates more confusion than
solution. You will fully understand what I mean by "bringing functional
concepts to OOP" only after you try to build some dummy project with
functional language. But hello word app will not be enough.

I recommend [Elixir](https://elixir-lang.org) and if you are Rails
developer try [Phoenix](http://phoenixframework.org)

### Other recommended resources & notes

* [Simplicity Matters by Rich Hickey](https://www.youtube.com/watch?v=rI8tNMsozo0)

Christmas is coming so I recommend books for you:

*  [Programming Elixir](https://pragprog.com/book/elixir/programming-elixir)
*  [Programming  Phoenix](https://pragprog.com/book/phoenix/programming-phoenix)


One note on MRI GLI lock:

Issue with single thread execution this will not be forever this way. Matz in
[changelog 202 interview](https://changelog.com/podcast/202) was
talking about how they are planing to push for "real"  parallelism in
Ruby 3 but it may still be few years till we get there.







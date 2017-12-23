# Write more explicit code layers !

> I'll demonstrate a Ruby on Rails example here, but the rules really apply to
> any programming language and any web framework.

Imagine you have a Rails controller that is creating a Book record

```ruby
# app/controllers/book_controller.rb
class BookController
  def create
    # ...
    @book = Book.create(params)
    # ...
  end
end
```

Tell me from looking at this code what data will be saved?

Well obviously it's a `Book` model so it will be some data related to
book right ?

But a `book` may mean different things in different applications:

* are we saving comprehensive book details (like in library)?
* are we saving some book price ? (like in book store?)
* maybe we are `book`ing  a ticket to concert

Ok lets have a look at the book model in Ruby on Rails.

```ruby
# app/models/book.rb
class Book < ActiveRecord::Base
  belongs_to :author
end
```

Hmm, I see there is an author, but I still cannot say what data are
saved related to book. We could run the `rails c` and inspect the `Book` model definition:


```ruby
Book.attribute_names
```

...but the only way to determine this directly from code is to look at **database schema** /
migrations definition or to look at **web interface**

Ok no big deal let's just have a look at `app/views/books/create.html.erb`

> If you never worked with Ruby on Rails, this is where the HTML code is stored. So
> we are trying to look at the HTML form definition and data that the
> form is sending.

Oh! I've forgot to tell you this RoR application is just an JSON API
and the Frontend code interface definition is not rendered with this
Rails app, but rather separate codebase NodeJS single page app (SPA).

> Yes Rails can render the single page frontend. But some companies
> likes to split into FE and BE teams working on separate codebase & separate technologies so that 
> everyone can implement their own favorite solutions. Teams can then
> deploy to different servers and the FE SPA is just communicating with
> BE APP via JSON API


So you need to go to other Github repository and check what the Frontend
is sending from there. And if you are not familiar with JS frameworks
then good luck.

Ok maybe your team is not split in such way or you are sending data from
HTML form that is rendered from `app/views`. But now you discovered that
that endpoint is actually an API that is called by your company partner,
or the app is a microservice.

**The point is that in these scenarios the Rails application is a separate
layer, an isolated bubble. There is a brick wall between your BE app
and something else. You cannot just throw garbage of values wrapped in a plastic bag
called `params` and push it directly to [ActiveRecord](http://guides.rubyonrails.org/active_record_basics.html) to save in DB. There needs to be an Explicit Interface defined!**

> "How about tests?".
>
> That's a good point. Your tests should be
> describing all the scenarios with all the various params received.
> But, from my experience once you are dealing with more complex test
> scenarios, tests will get break down to smaller object tests => you still need to
> spend some time to figure out what are the expected values.
>
> What I'll try to present here is more straight on communication of
> intention between developers.

So, did you spotted a security smell in my code by any chance?

I need to restrict permitted
parameters for this resource otherwise someone may set undesired values
(E.g. `book['author']['admin']=true`) :


And yes the solution for
this security smell will solve the need for explicit interface:

```ruby
# app/controllers/book_controller.rb
class BookController < ApplicationController
  def create
    # ...
    @book = Book.create(book_params)
    # ...
  end

  def book_params
     params.require(:book).permit(:title, :author_id, :price)
  end
end
```

This way we are allowing only to set `book.title`, `book.author_id` and
`book.price` and from this we can determine what the Book model is
really about.

Cool, we have an existing solution for this. But imagine you are
building complex search solution that is too big to be in a controller.

You can search `term` and apply several filters like:

* search `term`:  e.g. "ruby" as in "Programming Ruby"
* `publisher`:  e.g.: The Pragmatic Bookshelf => 'pragprog'
* `book_format`: `paper`, `hard` or `ebook`
* `favorite`: `true/false`
* ...and many more

e.g:

`GET localhost:3000/books?term=ruby&publisher=pragprog&favorite=true&book_format=ebook`

So you decide to use Service object (or Procedure Module):


```ruby
# app/controllers/book_controller.rb
class BookController < ApplicationController

  def index
    # ...
    @results = BookSearcher.find(params)
    # ...
  end
end
```


Similar to previous example, tell me from this code what the `BookSearcher`
is searching for ? You don't know do you ? Why because that
responsibility is passed to Searcher. Let's investigate that.


> We will use `ActiveRecord` example but the  BookSearcher search can be on ElasticSearch, DynamoDB, ... That's why we don't convert it to [Rails Query Object](http://www.eq8.eu/blogs/38-rails-activerecord-relation-arel-composition-and-query-objects)
> ...


```ruby
# app/services/book_searcher.rb
module BookSearcher
  extend self

  def find(params)
    scope = Book.all
    scope = scope.where("books.title LIKE ?", "%#{params['term']}%") if params['term']
    scope = scope.where('? = ANY (book_format)', params['book_format']) if params['book_format']

    if params['publisher'] && publisher = PublisherSearch.find(params)
      # do some search on publisher keyword and add condition to `scope`
    end

    # ...

    scope
  end
end

# app/services/book_searcher.rb
module BookSearcher
  extend self

  def find(params)
    publisher_keyword = params[:publisher]
    # ...it dosn't really matter what it does with `publisher_keyword`
  end
end
```

Let's just assume that `PublisherSearch` is used in some other controller
and we just want to reuse it.

So the way how this works is that `BooksController` will just pass all
the `params` to `BookSearcher.find(params)` depending on the values of
`params` we construct various SQL conditions directly on `Book` model
`ActiveRecord::Relation` scope
but when we need to do some search on `Publisher` keyword we just pass
the `params` to `PublisherSearch` which then takes value of
`params[:publisher]` to do some generic search used is some other place.


> "Wait a minute, `BookSearcher` is not a service object !"
>
> Recently Avdi Grimm published article [Enough with service objects](https://avdi.codes/service-objects/) where he argues that Object existence needs
> needs to be justified with receiver of message.
>
> I have problem with unjustified objects  as well (and therefore service objects) but in terms
> of unnecessary state holding that I've explained 
in my article [Lesson learned after trying functional programming](http://www.eq8.eu/blogs/46-lesson-learned-after-trying-functional-programming-as-a-ruby-developer)
>
> Normally I would just write Service object example as developers are
> more familiar with them and I want to prove different point
> but it's time to start separating `procedures` (transaction script)
> and `objects` as different thing.


Now let me rewrite the code differently


```ruby
# app/controllers/book_controller.rb
class BookController < ApplicationController

  def index
    # ...
    @results = BookSearcher.find({
      term: params[:term].blank? ? nil : params[:term],
      book_format: params[:book_format],
      publisher_keyword: params[:publisher]
      # ...
    })
    # ...
  end
end
```

Now before we continue to Service solution/Procedure module, tell me by just reading
this controller code what the `BookSearcher` could be searching for ?

Much easier isn't it ?

I'm passing a `term`, `book_format`, `publisher_keyword`, I can see which
arguments comes from `params` and therefore what the FE expects BE to
respond to.

```ruby
# app/services/book_searcher.rb
module BookSearcher
  extend self

  def find(term:, book_format:, publisher_keyword: )
    scope = Book.all
    scope = scope.where("books.title LIKE ?", "%#{term}%") if term
    scope = scope.where('? = ANY (book_format)', book_format) if
book_format

    if publisher_keyword && publisher = PublisherSearch.find(publisher_keyword: publisher_keyword)
      # ...
    end

    # ...

    scope
  end
end

# app/services/book_searcher.rb
module BookSearcher
  extend self

  def find(publisher_keyword:)
    # ...it dosn't really matter what it does with `publisher_keyword`
  end
end
```

It may not seems much but the difference is huge !

You don't pass `params` wildly to the rest of your application. It's clearly
define what you will pass to rest of your code layers.

By being more explicit we clearly distinguish
our controller to be a layer that holds responsibility of translating
values from `params`, forwarding values to appropriate place in our Service object / Procedure module

### Service example

Let say there is a good reason to satisfy `BookSearcher` to be a Service Object.
One scenario could be that you created platform where multiple companies
can host their online book store.

This way the service object is initialized based on `current_store`
(current client) and search options "filters" serves as attr_accessor object modifiers:


```ruby
# app/controllers/book_controller.rb
class BookController < ApplicationController

  def index
    # ...
    current_store = Store.find_by(session[:store_id])

    BookSearcher
      .new(store: current_store)
      .tap do |s|
        s.term   = params[:term]   unless params[:term].blank?
        s.book_format = params[:book_format]
        # ...
    })
    # ...
  end
end
```

As you can see we didn't loose the explicitness, we still can determine
what the search logic will be from here.

```ruby
# app/services/book_searcher.rb
class BookSearcher
  attr_reader :store
  attr_accessor :term:, :publisher_keyword
  attr_writer :book_format

  def initialize(store)
    @store
  end

  def find
    scope = store.books
    scope = scope.where("books.title LIKE ?", "%#{term}%") if term
    scope = scope.where('? = ANY (book_format)', book_format) if
book_format
    # ...
    scope
  end

  private
    def book_format
      store.supported_format?(book_format: @book_format) if @book_format
    end
end
```

### Request model

At this point you may say what we have lost the agility of the code. If we
want to introduce a new search parameter all we needed to do in our
"pass the `params` to service" example was just to add the logic in the
service. This way we need to update the Controller and any other
method/object dealing with this value.

Some may say that this is silly, all we need to do is to write a test on
how our service will behave when we pass it `params` in different forms.

Well all this is true, ...sort of.

Ever heard of **Request models** ?

They are type of objects that are just passed through your Controller
directly to Service object/s or Procedure module/s and you can test
different scenarios with them.

The catch is however that they need to be well defined and well explicit.  Plain `params`
or `OpenStruct.new` will not do the trick.

The problem with `params` is that it represents anything passed via
browser or JSON API. But limit it to only the stuff your app really
need e.g. `params.require(:book).permit(:title, :author_id, :price)`
and you got yourself sort of a Request Model.

But there is another gotcha to have full Request Model.
You just don't write tests on your Service
object when passing different Request Models to it, you also write tests on
different implementations of Request Models itself !

>  I've described [Request Models](http://www.eq8.eu/blogs/22-different-ways-how-to-do-contextual-rails-validations) bit further in my article [contextual validations in Rails](http://www.eq8.eu/blogs/22-different-ways-how-to-do-contextual-rails-validations).  I'm not planing to
> spend too much time explaining them here. But just to show you what I mean:

```ruby
# app/controllers/book_controller.rb
class BookController < ApplicationController

  def index
    request_object = BookSearchRequest.new(params)
    @result = BookSearcher.find(request_object)
  end
end
```


This way no longer the Controller is the explicit definition of your
endpoint but Request models are:

```ruby
# app/services/book_searcher.rb
module BookSearcher
  extend self

  def find(request_object)
    scope = Book.all
    scope = scope.where("books.title LIKE ?", "%#{request_object.term}%") if request_object.term
    scope = scope.where('? = ANY (book_format)', request_object.book_format) if request_object.book_format

    if publisher = PublisherSearch.find(request_object)
      # ...
    end

    # ...

    scope
  end
end
```


```ruby
# app/request_models/book_searcher_request.rb
class BookSearchRequest
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def term
    params[:term] unless params[:term].blank?
  end

  # ....

  def publisher
    PublisherRequest.new(params)
  end
end
```




```ruby
# app/request_models/book_searcher_request.rb
class PublisherSearchRequest
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def publisher_keyword
    params[:publisher]
  end
end

#app/service/publisher_search
class PublisherSearch
  extend :self

  def find(request_models)
    publisher_keyword = request_models.publisher_keyword
    # ....
  end
end
```

Example of tests e.g.:

```ruby
# spec/services/book_searcher_spec.rb
require 'rails_helper'
RSpec.describe BookSearcher do
  let(:result) { BookSearcher.find(request_object) }

  context 'when searching for term' do
    let(:request_object) { instance_double(BookSearchRequest, term: 'ruby') }

    it do
      # ....
    end
  end
  # ...
end
```

```ruby
# spec/services/book_searcher_spec.rb
require 'rails_helper'
RSpec.describe BookSearchRequest do
  subject { described_class.new(params) }

  context 'when term search'
    let(:params) { {'term' => 'ruby'} }

    it { expect(subject.term).to eq 'ruby' }
  end

  # ...
end
```


Let me just highlight that Request Models are really rare in my code. I
just use them when I 
need to deal with really complex request (e.g. bulk update). I rather prefer explicit service objects / procedure modules and controller actions passing  arguments from `params` to them as
dynamic nature of Request Models comes with price of overcomplication.

### Conclusion

If your application is one monolith holding both FE logic and BE logic
and everyone in your development team knows how to implement both of
this aspects then maybe you don't need this.

But if you are building application where you are trying to separate FE
/ BE or building application that consist of microservices or you are
implementing any form of code layering (e.g.: bounded contexts)
you need to be more explicit on interfaces.

You are trying to make your application as understandable as possible.
Help others to understand application communication.

> one of the biggest values of microservices is that they are "independent" of each other. You should be able to work
> on microservice A without the need of how microservice B is
> implemented. They just share a common contract of communication.

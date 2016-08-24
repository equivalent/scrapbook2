# Native RSpec JSON API testing

In this article we will have a look how to test JSON API in Ruby on
Rails or in plain Ruby application with nothing
more than RSpec 3.x

> Entire source code of Dummy applicaion can be found [here](https://github.com/equivalent/code_katas/tree/master/rspec_API_testing/demo_app)

### Ruby on Rails example

Let say we have `Article` model and `ArticlesController`

```ruby
# app/models/article.rb
class Article < ActiveRecord::Base
  def as_json
    {
      id: id,
      title: title
    }
  end
end
```

```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ActionController::Base
  before_action :find_article

  def show
    render json: @article.as_json
  end

  private
    def find_article
      @article = Article.find(params[:id])
    end
end
```

In order to test this we can write a RSpec test like:

```ruby
# spec/controllers/articles_controller_spec.rb
require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do

  describe "GET #show" do
    before do
      get :show, id: article.id
    end

    let(:article) { Article.create(title: 'Hello World') }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "response with JSON body containing expected Article attributes" do
      hash_body = nil
      expect { hash_body = JSON.parse(response.body).with_indifferent_access }.not_to raise_exception
      expect(hash_body).to match({
        id: article.id,
        title: 'Hello World'
      })
    end
  end
end
```


So in the last `it` statement  we are evaluating single logical
assertion whether response body is parsable  JSON format.
`JSON.parse` will throw an exception if this is not true.
The result of this is a parsed Hash that is saved `hash_body` that we
convert to Rails
[HashWithIndifferentAccess](http://api.rubyonrails.org/classes/ActiveSupport/HashWithIndifferentAccess.html) and we store this to local
variable.

> HashWithIndifferentAccess is typo of hash that in which symbol keys
> and string keys are considered same ( key `:id` is == key `"id"`)

Then we are using built in `RSpec` `#match` matcher that compares the
the hash elements. Unlike `eq` matcher you can pass other matchers as
arguments.

```ruby
      # ...
      expect(hash_body).to match({
        id: be_kind_of(Integer),
        title: match(/ello/)
      })
      # ...
```


Of course you don't want to repeat this part in every controller:

```ruby
      hash_body = nil
      expect { hash_body = JSON.parse(response.body).with_indifferent_access }.not_to raise_exception
```


Let's introduce a custom matcher and some helpers for this:

```ruby
# spec/spec_helper.rb
# ...
Dir["./spec/support/custom_matchers/**/*.rb"].each { |f| require f}
# ...

def body_as_json
  json_str_to_hash(response.body)
end

def json_str_to_hash(str)
  JSON.parse(str).with_indifferent_access
end
```

```
# spec/support/custom_matchers/json_matchers.rb
RSpec::Matchers.define :look_like_json do |expected|
  match do |actual|
    begin
      JSON.parse(actual)
    rescue JSON::ParserError
      false
    end
  end

  failure_message do |actual|
    "\"#{actual}\" is not parsable by JSON.parse"
  end

  description do
    "Expects to be JSON parsable String"
  end
end
```

Now you can write:

```ruby
# spec/controllers/articles_controller_spec.rb

    # ...
    it "response with JSON body containing expected Article attributes" do
      expect(response.body).to look_like_json
      expect(body_as_json).to match({
        id: article.id,
        title: 'Hello World'
      })
    end
    # ...
```

> Are you asking yourself: "Shouldn't `expect(body).to look_like_json` and `expect(body_as_json).to match` be in separate `it` blocks?".
> Well yes and no, we are testing two things (that's true) but both
> are there to ensure **one logical assertion**: "Is the body expected JSON ?"
> The `look_like_json` is just a safety check for in case that the
> `response.body` changes to some "non-json" (e.g. someone changes the
> `render :json` with `render :html`, this give you meaningful message
> what went wrong  before the comparison of JSON body even starts.
>
> If you want to learn more on this I'm recommending Bob Martins
> [Clean Code: Advanced TDD](https://cleancoders.com/videos)


Now this may be enough for small JSON APIs in small applications where
 controllers specs acts as a integration or smoke test.

## Going Plain Ruby - Serializer Objects

No matter if you're using Rails, Sinatra or Volt once it goes to
complex JSON APIs sticking all the JSON structure logic to Model or
Controller is a bad idea. This should be responsibility of some
**Serializer object** and Controller spec would just make sure it's
called correctly.

> Most used Rails solution is gem [ActiveModel Serializer](https://github.com/rails-api/active_model_serializers)
> but in this tutorial we are going to build our own Serializer object
> just to prove a point that you don't need anything fancy.

Let say we want to build your API to comply  [jsonapi.org
specification](http://jsonapi.org/) and the result should look like:

```json
{
  "article": {
    "id": "305",
    "type": "articles",
    "attributes": {
      "title": "Asking Alexandria"
    }
  }
}
```

```ruby
# spec/serializers/article_serializer_spec.rb

require 'rails_helper'

RSpec.describe ArticleSerializer do
  subject { described_class.new(article) }
  let(:article) { instance_double(Article, id: 678, title: "Bring Me The Horizon") }

  describe "#as_json" do
    let(:result) { subject.as_json }

    it 'root should be article Hash' do
      expect(result).to match({
        article: be_kind_of(Hash)
      })
    end

    context 'article hash' do
      let(:article_hash) { result.fetch(:article) }

      it 'should contain type and id' do
        expect(article_hash).to match({
          id: article.id.to_s,
          type: 'articles',
          attributes: be_kind_of(Hash)
        })
      end

      context 'attributes' do
        let(:article_hash_attributes) { article_hash.fetch(:attributes) }

        it do
          expect(article_hash_attributes).to match({
            title: /[Hh]orizon/,
          })
        end
      end
    end
  end
end
```

```ruby
# app/serializers/article_serializer.rb

class ArticleSerializer
  attr_reader :article

  def initialize(article)
    @article = article
  end

  def as_json
    {
      article: {
        id: article.id.to_s,
        type: 'articles',
        attributes: {
          title: article.title
        }
      }
    }
  end
end
```

When we run our "serializer" specs everything passes. That's pretty boring let's introduce a
typo to our Article Serializer. Instead of `type: "articles"` lets return `type: "events"` and rerun our tests

```bash
rspec spec/serializers/article_serializer_spec.rb

.F.

Failures:

  1) ArticleSerializer#as_json article hash should contain type and id
     Failure/Error:
       expect(article_hash).to match({
         id: article.id.to_s,
         type: 'articles',
         attributes: be_kind_of(Hash)
       })
     
       expected {:id=>"678", :type=>"event",
:attributes=>{:title=>"Bring Me The Horizon"}} to match {:id=>"678",
:type=>"articles", :attributes=>(be a kind of Hash)}
       Diff:
       
       @@ -1,4 +1,4 @@
       -:attributes => (be a kind of Hash),
       +:attributes => {:title=>"Bring Me The Horizon"},
        :id => "678",
       -:type => "articles",
       +:type => "events",
       
     # ./spec/serializers/article_serializer_spec.rb:20:in `block (4
levels) in <top (required)>'
```

It's pretty easy to spot the error. Let's fix this error and introduce
a different error, tell the Serializer to return title with 3 `l`

```bash
rspec spec/serializers/article_serializer_spec.rb 

..F

Failures:

  1) ArticleSerializer#as_json article hash attributes should match
{:title=>(be a kind of String)}
     Failure/Error:
       expect(article_hash_attributes).to match({
         title: be_kind_of(String),
       })

       expected {:titllle=>"Bring Me The Horizon"} to match {:title=>(be
a kind of String)}
       Diff:
       @@ -1,2 +1,2 @@
       -:title => /[Hh]orizon/,
       +:titllle => "Bring Me The Horizon",

     # ./spec/serializers/article_serializer_spec.rb:31:in `block (5
levels) in <top (required)>'
```

## Hooking Serializer to Controller

So far Serializer is just Ruby object that is not doing anything useful
from application point of view. Lets tell our Controller to use it:


```ruby
# app/controllers/v2/articles_controller.rb
module V2
  class ArticlesController < ApplicationController
    def show
      render json: serializer.as_json
    end

    private
      def article
        @article ||= Article.find(params[:id])
      end

      def serializer
        @serializer ||= ArticleSerializer.new(article)
      end
  end
end
```

As you can see we will just render the JSON hash via serializer
and pass it to `render json: ...`


Production code is the easy part, but in order to test this you need to ask yourself what
test philosophy is your team 
following. Do you like Stubbed Controller tests or Integration
Controller tests?

#### Controller spec as an Integration test version:

```rspec
require 'rails_helper'

RSpec.describe V2::ArticlesController do
  describe "GET #show" do
    def trigger
      get :show, id: article.id
    end

    let(:article) { Article.create(title: 'Hello World') }

    it "returns http success" do
      trigger
      expect(response).to have_http_status(:success)
    end

    it "respond body JSON with attributes" do
      trigger
      expect(response.body).to look_like_json
      expect(body_as_json).to be_kind_of(Hash)
    end

    it "correct article attributes are rendered" do
      # we are not stubbing we will just make sure the Serializer is
called
      expect_any_instance_of(ArticleSerializer)
        .to receive(:as_json)
        .and_call_original  # this will ensure the return value
                            # is called as it would normaly do

      trigger

      article_id = body_as_json
        .fetch(:article)
        .fetch(:id)
        .to_i

      expect(article_id).to eq article.id
    end
  end
end
```

In this kind of approach we just want to be sure our Serializer was
called but we don't need to test every attribute returned by JSON Body. That is already tested by Serializer test !.

We just want to be sure that correct Article JSON is rendered and we do
that by checking the id.

#### Stubbed Controller tests

If you are followers of Mockists test philosophy school. Your concern
is not to call something that we know is already working.
All you care is that the `ArticleSerializer` object was constructed
with correct `article` and `as_json` was called in order to `render
json: ...`

```ruby
require 'rails_helper'

RSpec.describe V2::ArticlesController do
  describe "GET #show" do
    def trigger
      get :show, id: article.id
    end

    let(:article) { Article.create(title: 'Hello World') }

    it "returns http success" do
      trigger
      expect(response).to have_http_status(:success)
    end

    context 'upon call' do
      before do
        serializer_double = instance_double(ArticleSerializer)

        expect(ArticleSerializer)
          .to receive(:new)
          .and_return(serializer_double)

        expect(serializer_double)
          .to receive(:as_json)
          .and_return(article: 'stubbed hash by ArticleSerializer')

        trigger
      end

      it "uses ArticleSerializer to render body JSON" do
        expect(body_as_json).to match(article: 'stubbed hash by ArticleSerializer')
      end
    end
  end
end
```

## Why ?

One of the benefits of Ruby on Rails community is the endless source of
libraries for various usecases and test cases. When you're building JSON
API using Ruby you have many choices of gems how you going to test this.

I'm just puzzled by the amount of gems Rails developer installs
by default in order to do simple application. In some cases some gems
make perfect sense but in lot cases they are just unecesary owerload and
once they used your Application relies on them.

RSpec is was is probably best test library in the world, no language
has better tool (in my opinion) it's just lot of time Rails Developers
don't try to understand it and variety of use cases it covers and they
automatically jump to random other test gem.



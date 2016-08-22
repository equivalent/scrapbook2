# Native RSpec JSON API testing

In this article we will have a look how to test JSON API with nothing
more than RSpec 3.x

Let say you have a controller

```ruby
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



## Why ?

One of the benefits of Ruby on Rails comunity is the endless source of
libraries for various usecases and test cases. When you're building JSON
API using Ruby you have many choices of gems how you going to test this. But I'm
really puzzled that pe...



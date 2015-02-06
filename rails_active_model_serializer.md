
# pasing  params to serializer from controller

```ruby
class Api::CategoriesController <  ApplicationController
  respond_to :json
  def index
    @categories = Category.all
    respond_with @categories, counter_value: params[:counter]
  end
end

class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :content_counter
  has_many :chapters

  def chapters
     object.chapters.active.with_counter(@options[:counter_value])
  end
end
```

http://stackoverflow.com/questions/23079307/how-can-i-pass-params-from-a-controller-to-my-serializers

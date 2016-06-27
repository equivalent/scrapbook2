# Rendering Paperclip attachment via elasticsearch

resources:

* [Paperclip lib](https://github.com/thoughtbot/paperclip)
* [Elastic search]
* ruby elastic search model lib


Imagine that we have existing system that is storing file attachments
in a Ruby on Rails application with
Paperclip library and persisting reference to relational database
(e.g.: PostgreSQL).

So for example we will have a dummy Real Estate application that have resource `Property`
showing description of the property. `Property`

 and images

For simplicity of code examle  we are rendering just urls via JSON API


```ruby
# Gemfile

# ...
gem 'pg'

gem 'elasticsearch-model'
gem 'elasticsearch-rails'

gem 'paperclip'
# ...
```

```ruby
# app/model/property.rb
class Property < ActiveRecord::Base
  # DB attributes :id, :title, :description

  has_many :images
end

# app/model/image.rb
class Image < ActiveRecord::Base
  # DB attributes :id, attachment_file_name, :updated_at

  belongs_to :property
  has_attached_file :attachment, styles: { thumb: '100x100>', screen: '1024x1024' }

  def screen_url
    attachment.url(:screen)
  end

  def thumb_url
    attachment.url(:thumb)
  end
end

# app/serializer/properties_serializer.rb
class PropertesSerializer
  attr_reader :collection

  def initialize(collection:)
    @collection = collection
  end

  def as_json
    collection.map do |property|
      {
        id: property.id,
        title: property.title,
        description: property.description,
        images: property.map do |image|
          {
            thumb:  image.thumb_url
            screen: image.screen_url
          }
        end
      }
    end
  end
end


# app/controller/properties_controller.rb
class PropertiesController < ApplicationController
  def index
    render json: properties_as_json, layout: false
  end

  private
    def set_properties
      if search_term
        @properties = Property.where("title LIKE '%?%'", search_term)
      else
        @properties = Property.all
      end
    end

    def search_term
      params["q"]
    end

    def properties_as_json
      PropertesSerializer.new(collection: @properties).as_json
    end
end

# config/routes.rb
# ...
resources :properties, only: [:index]
# ...
```

```bash
curl localhost:3000/properties?q=cool
```

```json
[
   {
     "id": 123,
     "title": "really cool property",
     "description":"foobar",
     "images": [
       {
         "thumb":  "http://localhost:3000/..../thumb/foo.jpg"
         "screen": "http://localhost:3000/..../screen/foo.jpg"
       },
       {
         "thumb":  "http://localhost:3000/..../thumb/bar.jpg"
         "screen": "http://localhost:3000/..../screen/bar.jpg"
       }
     ]
  }
]
```


Lets introduce elasticsearch


```ruby
# app/model/property.rb
class Property < ActiveRecord::Base
  # ...

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # ...

  def as_indexed_json
    {
      id: id,
      title: title,
      description: description,
      images: images.map(&:as_indexed_json)
    }
  end
end
```

```ruby
# app/model/image.rb
class Image < ActiveRecord::Base
  # No need to add any elasticsearch includes here
  # ...

  def as_indexed_json
    {
      thumb_url: image.thumb_url,
      screen_url: image.screen_url,
      updated_at: image.updated_at
    }
  end
end
```


```ruby
# app/controller/properties_controller.rb
class PropertiesController < ApplicationController
  def index
    render json: properties_as_json, layout: false
  end

  private
    def set_properties
      if search_term
        @properties = Property.search({
          query: {
             term: { title: search_term }
          }
        })
      else
        @properties = Property.search(match_all: {})
      end
    end

    def search_term
      params["q"]
    end

    def properties_as_json
      PropertesSerializer.new(collection: @properties).as_json
    end
end
```

> `Property.search` is just alias for 
> `Property.__elasticsearch__.search` provided by Elasticsearch gem



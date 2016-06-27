# Rendering Paperclip attachment via elasticsearch

resources:

* [Paperclip lib](https://github.com/thoughtbot/paperclip)
* [Elasticsearch Rails](https://github.com/elastic/elasticsearch-rails)
* [source code example](https://gist.github.com/equivalent/ba7835e07fabc4ba103008f553dc2e3a)


Imagine that we have existing system that is storing file attachments
in a Ruby on Rails application with
Paperclip library and persisting reference to relational database
(e.g.: PostgreSQL).

So for example we will have a dummy Real Estate application that have resource `Property`
showing `#title` and `#description` of the property. Property has many
`images`.

For simplicity of in our code examle we are rendering just urls via JSON API but same principals will apply
if you want to generate server side HTML via ERB, Slim, Haml, ...

## Relational DB example first

```ruby
# Gemfile

# ...
gem 'pg'

gem 'paperclip'
# ...
```

```ruby
# app/model/property.rb
class Property < ActiveRecord::Base
  # DB attributes :id, :title, :description

  has_many :images
end
```

```ruby
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
```

```ruby
# app/serializer/properties_serializer.rb
class PropertesSerializer
  attr_reader :collection

  def initialize(collection:)
    @collection = collection
  end

  def as_json
    collection.map do |property|
      {
        id: property.id.to_i,
        title: property.title,
        description: property.description,
        images: property.images.map do |i|
          {
            thumb:  i.thumb_url
            screen: i.screen_url
          }
        end
      }
    end
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
```

```ruby
# config/routes.rb
# ...
resources :properties, only: [:index]
# ...
```

So basically we have `PropertiesController` that is just rendering JSON.
Result will contain either all records when not searched, or just
results matchinch the search query.


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


## Lets introduce Elasticsearch


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
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  mapping do
    indexes :title
  end

  has_many :images

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
  belongs_to :property, touch: true
  has_attached_file :attachment, styles: { thumb: '100x100>', screen: '1024x1024' }

  def screen_url
    attachment.url(:screen)
  end

  def thumb_url
    attachment.url(:thumb)
  end

  def as_indexed_json
    {
      id:         image.id,
      updated_at: image.updated_at,
      attachment_file_name: image.attachment_file_name,
    }
  end
end
```

We've included Elasticsearch modules to `Property` model

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


```ruby
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
        images: property.images.map do |es_image|
          {
            thumb:  es_image_to_image(es_image).thumb_url,
            screen: es_image_to_image(es_image).screen_url
          }
        end
      }
    end
  end

  # This image instance is purely for generating urls don't
  # persist any data on it
  #
  def es_image_to_image(es_image)
    Image.new({
      id:         es_image.id,
      updated_at: es_image.updated_at,
      attachment_file_name: es_image.attachment_file_name,
    })
  end
end
```

Lunch Rails console and run:

```ruby
Property.__elasticsearch__.create_index!
Property.import
```

...and restart Rails server.

Now you should have fully functional Elasticsearch that is rendering
image urls without the need to access PostgreSQL data.

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


Source:

* https://gist.github.com/equivalent/ba7835e07fabc4ba103008f553dc2e3a
* https://gist.github.com/equivalent/310a948f9d6b4ade0ce1cb243e995569

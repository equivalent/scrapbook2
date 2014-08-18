http://guides.rubyonrails.org/caching_with_rails.html

# Silence caching log 

``ruby
# confing/enviroment.rb
Rails.cache.silence!
```

# model caching solutions

### cache scenario: cache find(id)

```ruby
class Event < ActiveRecord::Base
  after_commit :flush_cache

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) { find(id) }
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end
end

e = Event.cached_find(2)
e.delete # this will flush cache
```

# Fragment caching


```erb
  <% cache('all_available_products') do %>
    All available products:
  <% end %>
```

exipire this with

```erb
    expire_fragment('all_available_products')  # in controller
```

# clear flush cache

    Rails.cache.clear

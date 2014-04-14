# Temporary enable dalli store in RSpec specs

When you writing tests/specs is good practice to have your test environment cache store set to `:null_store`.

```ruby
# config/environments/test.rb

MyApp::Application.configure do
  #...
  
  config.cache_store = :null_store
end
```

This way you will ensure that nothing is cached during test/spec run.

However there are cases where when you write a spec, you want the cache work same as it will in production env (e.g. 
cache store with Dalli). No worries you don't have to switch the entire enviroment cache store, just use helper
similar to this one :


```ruby
# spec/support/temp_enable_dalli_cache_helpers
module TempEnableDalliCacheHelpers
  def temp_enable_dalli_cache!
    let(:cache){ ActiveSupport::Cache::DalliStore.new }
    before do
      Rails.stub(:cache).and_return(cache)
    end
    after do
      Rails.unstub(:cache)
    end
  end
end
```

make sure that your `support` folder is loaded in `spec_helper.rb`

```ruby
# spec/spec_helper.rb

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ...
end
```

and now all you have to do is include this module in you spec and you call `temp_enable_dalli_cache!` inside
the `describe` block which you want to work with cache

```ruby
# spec/models/user.rb

require 'spec_helper'
include TempEnableDalliCacheHelpers

describe User do

  describe '#coments_count' do
    temp_enable_dalli_cache!
  
    it 'should fetch value from cache' do
      #...
    end
  end
end

```

if you want this module included in all specs you have to extend RSpec configuration like this 

```ruby
# spec/spec_helper.rb

#...
RSpec.configure do |config|
  config.extend TempEnableDalliCacheHelpers
  # ...
end
```

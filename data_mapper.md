

```ruby
require 'data_mapper'

before :all do
  DataMapper.setup(:default, 'sqlite::memory:')
  DataMapper.auto_migrate!
end


class Endorsement
  include DataMapper::Resource

  property :gem_name, String, key: true

  def self.all_for_gem_named(name)
    all(gem_name: name)
  end
end

```

source: ruby tapas 46

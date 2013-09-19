# RSpec scrapbook

### Install

    group :test, :development do
      gem "rspec-rails", "~> 2.13"
    end

### Setup & generator 

    rails g rspec:install
    rails g rspec:model platform

### Fixture

    # spec/something_spec.rb
    require 'spec_helper'
    describe Something do
      fixtures :platforms
    # ...
    

### Factories with [FactoryGirl](https://github.com/thoughtbot/factory_girl)

```ruby
FactoryGirl.define do
  factory :country do
    name "Tomi-land"
    existing: true

    sequence(:description) { |n| "Country description no #{n}." }

    trait :used_in_address do
      address_ids { [FactoryGirl.create(:address).id] }
    end
    
    trait :cached_in_past do
      after :create do |country|
        country.update_column :cached_at, 2.days.ago
      end
    end
  end
    
  factory :vanished_countries, class: 'Country' do
    existing: false
    after :build do |country|
      country.do_something_meaningful
    end
  end
  
end

# call with traits
FactoryGirl.create :country, :cached_in_past, cities: [city1, city2]
```

sources

* https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md

rails 3.2.12



### require support folder
    
    # spec/spec_helper.rb
    Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}       # rails
    Dir[File.dirname(__FILE__)+"/support/**/*.rb"].each {|f| p  require f}  # pure ruby

### Matchers

    2.1.should_not be_within(delta).of(2.0)  # e.g.: delta = 0.2 
    user.updated_at.should_not be_within(10.seconds).of(Time.now)

## Mocking and Stubbing 

### Stub

```ruby
obj.stub(:message).with(anything()) { ... }
obj.stub(:message).with(an_instance_of(Money)) { ... }
obj.stub(:message).with(hash_including(:a => 'b')) { ... }
```

source: https://www.relishapp.com/rspec/rspec-mocks/v/2-14/docs/method-stubs


### null objects mocks

> Use the as_null_object method to ignore any messages that aren't explicitly
> set as stubs or message expectations

...in other words you can stub method with null object without worrying you'll receive  error messages from parts of application you are not interested in spec

Let say I have `Registry` model with several after_create callbacks to clear several cache keys, yet I'm explicitly interested if one particular cache key is cleared (let say another spec that is testing if  the other cache key cleared) 

```ruby
describe Registry do
  describe 'creation'
    it 'should clear ultracool cache' do
      Rails.cache.should_receive(:delete).with('ultracool')
      Rails.cache.should_receive(:delete).and_return(double(:null).as_null_object) #ignore other clearances of cache
      Registry.create name: 'foo'      
    end
  end
end
```

sources: https://www.relishapp.com/rspec/rspec-mocks/v/2-6/docs/method-stubs/as-null-object

published: 2013-09-12

### tweek you Garbage Collector so that tests run faster

```bash
time rspec spec
export RUBY_GC_MALLOC_LIMIT=90000000
export RUBY_FREE_MIN=200000
time rspeec spec  
```
source: http://fredwu.me/post/60441991350/protip-ruby-devs-please-tweak-your-gc-settings-for?utm_source=rubyweekly&utm_medium=email

my colleague gave me this:

```bash
# Ruby GC
#
# RUBY_GC_MALLOC_LIMIT
# The amount of C data structures which can be allocated without triggering a garbage collection. Default: 8000000
#
# RUBY_HEAP_SLOTS_GROWTH_FACTOR
# Multiplicator used for calculating the number of new heaps slots to allocate next time Ruby needs new heap slots. Default: 1.8
#
# RUBY_HEAP_MIN_SLOTS
# Initial number of heap slots. Default: 10000
#
# RUBY_FREE_MIN
# The number of heap slots that should be available after a garbage collector run. If fewer heap slots are available, then Ruby will allocate a new heap. Default: 4096
#
export RUBY_GC_MALLOC_LIMIT=1000000000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1.25
export RUBY_HEAP_MIN_SLOTS=800000
export RUBY_FREE_MIN=600000
```

published: 2013-09-13

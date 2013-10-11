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
    existing true
    short_description  Faker::Lorem.paragraph  # With Faker gem

    sequence(:long_description) { |n| "Country description no #{n}." }
    
    trait :used_in_address do
      address_ids { [FactoryGirl.create(:address).id] }
    end
    
    trait :cached_in_past do
      after :create do |country|
        country.update_column :cached_at, 2.days.ago
      end
    end
  end
    
  factory :vanished_country, class: 'Country' do
    existing false
    
    after :build do |country|
      country.do_something_meaningful
    end
  end
  
end

# call with traits
FactoryGirl.create :country, :cached_in_past, cities: [city1, city2], short_description: 'my desc'
```

sources

* https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md

rails 3.2.12



### [Shoulda matchers](https://github.com/thoughtbot/shoulda-matchers)

    it{ subject.should have(1).error_on(:last_name) }
    
* [Shoulda Matchers callbacks](https://github.com/equivalent/shoulda-matchers-callbacks)
* [Shoulda Matchers assign_to](https://github.com/tinfoil/shoulda-kept-assign-to)
* [Deprication of certain shoulda matchers ](https://github.com/equivalent/scrapbook2/blob/master/archive/blogs/shoulda_matchers_deprecated_what_now.md)


### require support folder
    
    # spec/spec_helper.rb
    Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}       # rails
    Dir[File.dirname(__FILE__)+"/support/**/*.rb"].each {|f| p  require f}  # pure ruby

### Matchers

**Compare in delta**

    2.1.should_not be_within(delta).of(2.0)  # e.g.: delta = 0.2 
    user.updated_at.should_not be_within(10.seconds).of(Time.now)

**Check existenc of error on record**

    publication.valid?
    publication.should have(1).error_on(:owner_type)

    

**Argument matchers**

```ruby
atm.should_receive(:withdraw).with(50, saving_account)
atm.should_receive(:withdraw).with(instance_of(Fixnum), saving_account)
atm.should_receive(:withdraw).with(anything(), saving_account)
atm.should_receive(:withdraw).with(any_args())
atm.should_receive(:withdraw).with(no_args())
bank.should_receive(:transaction).with(hash_including(name: 'Jhon'))
bank.should_receive(:transaction).with(hash_not_including(wife: 'Teresa'))

# argument match regular expression
resource.should_receive(:check_type).with(/*User/)

# custom argument matcher

class GreaterThanThreeMatcher
  def ==(actual)
    actual > 3
  end
end

def greater_than_three
  GreaterThanThreeMatcher.new
end

it{ calculator.should_receive(:add).with(greater_than_three)

``` 

**Call original**
# stub and call original

```ruby
class Pokemon < ActiveRecord::Base
  def do_pokemon_shit
    a = cool_power || build_cool_power
    a.do_stuff_with_cool_power
  end

  def do_stuff_with_cool_power
    #do something meaningfull related to cool_power
    'something'
  end
end

describe Pokemon
  let(:pokemon){ Pokemon.new }

  describe do_pokemon_shit do
    it 'try it out' do 
      pokemon.should_recive(:build_cool_power).and_call_original
      pokemon.do_stuff_with_cool_power.should eq  'something'
    end
  end
end
```

rails 3.2.12
date: 2013-05-02
rspec 1.8.25
ruby 2.0.0
sources: https://www.relishapp.com/rspec/rspec-mocks/v/2-12/docs/message-expectations/calling-the-original-method
keywords: stub and call original rspec mock double object and call original

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


## Code Examples

```ruby 
class User < ActiveRecord::Base
  
  def healthy_teeth
    32
  end
    
  def eligeble_to_volte?
    age > 18
  end
end


describe User

  it{ should have(32).healthy_teeth} 
  it{ should be_eligeble_to_volte }
  it{ 3.should == 3 }
  it{ 'three'.should =~ /hre/ }
  it{ 3.should be >= 2 }
  it{ 3.should be <= 4 }
  
  it{ ->{ something }.should raise_error }
  it{ expect{ service }.to raise_error }
  it{ expect{ service }.to raise_error SomeStrangeError }
  it{ expect{ service }.to raise_error /error message/ }
  it{ expect{ service }.to raise_error SomeStrangeError, /error message/ }
  
  it do
    network_double.should_receive(:open_connection).never
    network_double.should_receive(:open_connection).exactly(0).times
    network_double.should_receive(:open_connection).at_least(1).times
    network_double.should_receive(:open_connection).at_most(5).times
    network_double.should_receive(:open_connection).once
    network_double.should_receive(:open_connection).twice
  end

  it do
    # stub chain
    #
    #    Article.recent.published.authored_by(params[:id]
    #
    Article.stub_chain(:recent, :published, :authored_by).and_return(author)
  end
    
  

end
```

```ruby
describe ErrorsController

  context '404 page' do
    before{ get :show, status: 404, format: 'html' }

    it{ should respond_with(:success)}
    it{ should render_template('errors/404')}
    it{ should render_template('layouts/error_page')}
    it{ assigns(:title).should  eq "Page not found" }
    it{ assigns(:status).should eq '404' }
  end
  
  context 'unknown status' do
    it{ expect{get :show, status: 123}.to raise_error }
  end  
end
```

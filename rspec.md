# RSpec scrapbook

capybara rspec cheat sheet:  http://cheatrags.com/capybara


### post create file to rails controller in RSpec

```ruby
  describe 'POST create' do
    it do
      params = {
        "utf8"=>"✓",
        "document"=>{
          "attachment"=>ActionDispatch::Http::UploadedFile
            .new(tempfile: File.open(Rails.root.join('spec', 'fixtures','passport.jpg')))
        },
        format: 'js' #html js #it's up  to you
      }
      post :create, params
    end
  end
```

you may also need to add `filename: File.basename(document), type:
"image/jpeg"` depending on what you doing`

### RSpec datetime Factory at midnight

one way how to deal whith factory times beeing out of sync:

```ruby
it 'user updated_at should not change' do 
  user = User.create(updated_at: Time.now.midnight) 
  do_some_calculation
  expect(user.updated_at).to eq(Time.now.midnight) 

  # Time.now.midnight will give you 2014-12-11 00:00:00 +0000
  # there is also .middle_of_day 2014-12-11 12:00:00 +0000
end
```

but I'm recommending to use  `Expect(Time.now).to be_within(2.seconds).of(Time.now)`

### check if yield

```ruby
  def my_method(value)
    yield if value
  end

  describe '#my_method' do
    #using plain ruby
    it 'should make sure that yield' do
      yielded = :not_yielded_yet
      my_method(true) do
        yielded = :was_yielded
      end

      expect(yielded).to eq(:was_yielded)
    end

    it 'should make sure that was not yield' do
      yielded = :not_yielded_yet
      my_method(false) do
        yielded = :was_yielded
      end

      expect(yielded).to eq(:not_yielded_yet)
    end

    it 'should yield' do
      expect { |block| my_method(true, &block) }
        .to yield_control.once
    end

    it 'should yield' do
      expect { |block| my_method(false, &block) }
        .not_to yield_control
    end
  end
```


### skip before


https://coderwall.com/p/_yrafw/skipping-before-hook-for-a-few-test-cases-in-rspec

```
before do
  unless example.metadata[:skip_before]
    # before body
  end
end

it "does something" do
  # before hook will run before this example
end

it "does something else", skip_before: true do
  # before hook will be skipped
end
```

### shared examples

```ruby
include_examples "name"      # include the examples in the current context
it_behaves_like "name"       # include the examples in a nested context
it_should_behave_like "name" # include the examples in a nested context
matching metadata            # include the examples in the current context
```

```ruby
RSpec.shared_examples "a collection" do
  let(:collection) { described_class.new([7, 2, 4]) }

  context "initialized with 3 items" do
    it "says it has three items" do
      expect(collection.size).to eq(3)
    end
  end
end

RSpec.describe Array do
  it_behaves_like "a collection"
end
```


source: https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples

### unstub

```ruby
before { Lpgrid::Configuration.any_instance.stub(:file_path).and_return('foo') }

before { Lpgrid::Configuration.any_instance.unstub(:file_path) }
```


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
    
    
### Factory Girl

moved to own file https://github.com/equivalent/scrapbook2/blob/master/factory_girl.md

### [Shoulda matchers](https://github.com/thoughtbot/shoulda-matchers)

    it{ subject.should have(1).error_on(:last_name) }
    it{ described_class.new(role: 'Admin').tap(&:valid?).should have(:no).errors_on(:role) }
    it { should allow_value('http://foo.com', 'http://bar.com/baz').for(:website_url) }
    it { should_not allow_value('asdfjkl').for(:website_url) }

    
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
    
         
    expect { service_reject }
      .to change { application.status_changed_at }
      .from(nil)
      .to(be_within(3.seconds).of(Time.now))
    

**Check existenc of error on record**

    publication.valid?
    publication.should have(1).error_on(:owner_type)
    
    should have_at_least(4).items 
    should have_at_most(2).items

    

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

#### Stub and call original

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

* rails 3.2.12
* date: 2013-05-02
* rspec 1.8.25
* ruby 2.0.0
* sources: https://www.relishapp.com/rspec/rspec-mocks/v/2-12/docs/message-expectations/calling-the-original-method
* keywords: stub and call original rspec mock double object and call original

## Mocking and Stubbing 

### Stub

```ruby
obj.stub(:message).with(anything()) { ... }
obj.stub(:message).with(an_instance_of(Money)) { ... }
obj.stub(:message).with(hash_including(:a => 'b')) { ... }
```

### Doubles

####Mock model

```ruby
client = mock_model Clent, method1: 'foo', coumn1: 'xxx'
client.method1: 'foo'

```

#### Factory Girl build vs build_stubbed

```ruby
FactoryGirl.define do
  factory :client do
    sequence(:name) { |n| "Client #{ n }"}
  end
end

describe Client do
  it do 
    build :client
    create :client
    build_stubed :client
    
  end
end

```

read more: http://robots.thoughtbot.com/use-factory-girls-build-stubbed-for-a-faster-test


#### Factory Girl attributes_for

let say you want to post valid attributes, if you use FactoryGirl you can get them with `attributes_for` method

```ruby
let(:attributes) { attributes_for(:content).stringify_keys }
it do
  post :create, content: attributes
end
```

source: https://www.relishapp.com/rspec/rspec-mocks/v/2-14/docs/method-stubs


### url_for and rails controller helpers for Helper specs

check https://github.com/equivalent/scrapbook2/blob/master/rails_action_dispatch_and_routing.md#how-to-access-url-helpers-from-cosole--specs--tests


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

## Configuring RSpec

### configure rspec and spork

Gemfile

```
# Gemfile
group :development, :test do
  gem 'rspec-rails'
end
```

tell RSpect to use drb server (spork) by default

```
# .rspec
--colour --drb
```

...todo


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
  it{ expect{ subject }.to change{User.count} }

  
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

### Example of `rspec_helper`

this is from old project I'm not recommending to just paste it, rather just pick bits and pieces 


```ruby
# spec/spec_helper.rb

require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'

  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'capybara/rspec'
  require 'factory_girl_rails'
  require 'database_cleaner'
  require 'sunspot_test/rspec'

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  #$original_sunspot_session = Sunspot.session
  #Sunspot::Rails::Tester.start_original_sunspot_session

  RSpec.configure do |config|
    config.infer_base_class_for_anonymous_controllers = false

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true

    config.include FactoryGirl::Syntax::Methods

    # Devise
    config.include Devise::TestHelpers, :type => :controller
    config.extend ControllerMacros, :type => :controller
    config.include RequestMacros, :type => :request

    # Sunspot Solr
    #config.before do
    #Delayed::Worker.delay_jobs = false
    #Sunspot.session = Sunspot::Rails::StubSessionProxy.new($original_sunspot_session)
    #config.before :each, :solr => true do
    #Sunspot.session = $original_sunspot_session
    #Sunspot.remove_all!
    #end
    #end

    # Helpers
    config.include Haml::Helpers , :type => :helper
    config.include ActionView::Helpers, :type => :helper
    config.before :each, :type => :helper do
      init_haml_helpers
    end

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end
end

Spork.each_run do
  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  FactoryGirl.reload
end 
```

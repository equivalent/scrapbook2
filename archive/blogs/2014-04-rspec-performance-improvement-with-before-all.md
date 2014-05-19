# RSpec performance improvements with before all

When it comes to RSpec every developer heavily uses `before(:each)` or
`after(:each)` hooks and kinda knows that something like
`before(:all)` exist but is not used often. Well why should it be ?

As your application grows your tests take longer and longer, and you
actually discover you have far more coffee breaks than you use to.

Reason for this is obvious: Your tests are hitting database too many times.
 
## The example

We will be demonstrating specs on simple candy that have many ingredients:

```ruby
# db/migrations/2014***********_create_candies.rb
class CreateCandies < ActiveRecord::Migration
  def change
    create_table :candies do |t|
      t.string :name
    end
  end
end

# db/migrations/2014***********_create_ingredients.rb
class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.integer :candy_id
      t.string  :name
    end
  end
end

# app/model/candy.rb
class Candy < ActiveRecord::Base
  has_many :ingredients
end

# app/model/ingredietns.rb
class Candy < ActiveRecord::Base
  belongs_to :candy
end
```

## How to write specs (...in Utopia) 

So let say you are starting new project, you can afford to avoid hitting
database by using `rspec-rails` gem mock helpers like `mock_model`, via
RSpec `double` - `stub` combination, or if you use [Factory Girl](https://github.com/thoughtbot/factory_girl)
gem via awesome helpers `build` and `build_stubbed`

**RSpec Rails `mock_model`**

```ruby
# spec/models/candy_spec.rb
describe Candy do
  
  let(:candy) { mock_model(Candy, id: 123, name: 'Chocolate') }
  
  describe "#name" do
    subject { candy.name }
    it { should eq 'Chocolate' }
  end
end
```

**Factory Girl `bulid` and `build_stubbed`**

```ruby
# spec/factories/candies.rb
FactoryGirl.define do
  factory :candy do
    name 'Chocolate'
  end
end

# spec/factories/ingredietns.rb
FactoryGirl.define do
  factory :ingredient do
    name 'Milk'
  end
end

# spec/models/candy_spec.rb
describe Candy do
  let(:candy1) { build(:candy) }
  let(:candy2) { build(:candy, name: 'Jelly Beans') }

  describe "#id" do
    it 'demonstrate :id' do
      candy1.id  # => nil
      candy2.id  # => 1001
    end
  end
  
  describe "#name" do
    it { candy1.name eq 'Chocolate' }
    it { candy2.name eq 'Jelly Beans' }
  end

  describe "#ingredients" do
    let(:ingredient) { build :ingredient }
    before { candy1.ingredients = [ingredient] }
   
    it { candy1.ingredients.should include ingredient } 
  end
end
```

This way you can associate one model into another without hitting the
database ever again! ...well not really. Sooner or later you will have
complicated scenario that would either took long time to write/rewrite as a
memory test or the database-hitting test would be easier, more readable or
less fragile.

Or maybe new junior developer will create his first pull request and
you wont have time explain to him the theory of survival in tests world.

## Wild Wild Specs

Problem starts with someone writing the first spec that saves to 
database. From that point less discipline developers will be copying
the code (one way or another) without truly caring that number of
database queries are growing.

Basically you end up with something like this:

```ruby
# spec/factories/candies.rb
FactoryGirl.define do
  factory :candy do
    name 'Chocolate'
   
    trait :with_ingredients do
      after(:create) do |candy|
        create(:ingredient, candy: candy)
        create(:ingredient, candy: candy, name: 'Sugar')
      end
    end
  end
end

# spec/mailers/candy_mailer_spec.rb
describe CandyMailer do
  let(:candy) { create(:candy, :with_ingredients) }

  describe "#send_ingredients" do
    let(:mail) { described_class.restock_candy_ingredients(candy)) }

    it { expect(mail.subject).to eq 'Ingredients for Chocolate' }
    it { expect(mail.body).to match '<h1>Chocolate</h1>'  }
    it { expect(mail.body).to match '<span style="color: red">Milk<span>' }  #ingredient 1
    it { expect(mail.body).to match '<span style="color: red">Sugar<span>' } #ingredient 2
  end
end
```

Although this example can be written without even touching the Database,
lets just assume that `candy` needs to be be created due to some
difficult technical difficulty or association.

This way we ended up with 4 `it` statements, each will create not only
the `candy` but its `ingrediens` as well. That means 3 SQL calls per
`it` statement totalling 12 sql calls per this simple test file.

More you write tests related to `candy` that requires `create` instead
of `build` or more complex your associations grow,  slower your tests
will get.


## Before :all to rescue !

Lets look at this example from different perspective:

```ruby
# spec/mailers/candy_mailer_spec.rb
describe CandyMailer do
  attr_reader :candy

  before(:all)
    @candy = create(:candy, :with_ingredients) }
  end

  after(:all)
    Candy.destroy_all
    # if you use Database Cleaner gem I recommend usage of :
    # DatabaseCleaner.clean_with :deletion
  end

  describe "#send_ingredients" do
    let(:mail) { described_class.restock_candy_ingredients(candy)) }

    it { expect(mail.subject).to eq 'Ingredients for Chocolate' }
    it { expect(mail.body).to match '<h1>Chocolate</h1>'  }
    it { expect(mail.body).to match '<span style="color: red">Milk<span>' }  #ingredient 1
    it { expect(mail.body).to match '<span style="color: red">Sugar<span>' } #ingredient 2
  end
end
```

This way we will trigger 3 SQL calls in the beginning of spec and 
each `it` statement will work with those resources without more Database
calls.

Keywords: Rails 4, Ruby 2, RSpec, before all, after all, test-suite, TDD

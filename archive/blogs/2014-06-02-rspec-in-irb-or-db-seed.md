# RSpec matchers in db:seed file

In my latest project I ended up with really complex `db/seeds.rb` file
for different clients so that various scenarios can be demonstrated on
a "demo" server. 

Ten minutes before meeting people were running crazy that
they cannot log-in to the demo server. Within nine minutes I manage to
locate the bug and fix it & deploy the fix. Well the bug was not even
a bug, it was just a typo in `db/seeds.rb` file. 

This was kind of a revelation for me. Old mind-set that "db seed 
files don't need tests as they represent temporary state" was replaced
with "yes they do need tests if they are subject to frequent change or
dynamic business requirement"

## how to test db:seed

The way how I'm testing my seed files is within the seed files at the
end of reseed. Yes this may not be the best idea because to discover 
that something went wrong we are destroying old database values. But in my
case (where I keep really good track of database dumps) it works for
me.

```ruby
# Gemfile

# ...

gem 'rspec-rails' 

# ...

```

```ruby
# db/seeds.rb
require 'rspec/expectations'

case Rails.env.to_s
when 'staging'
  # ...
when 'demo'
  include RSpec::Matchers   # important !
  
  # adding people & permissions
  carl = User.create email: 'carl@test.com'
  carl.add_permission :admin

  # tests
  expect(User.find_by email: 'carl@test.com').to be_present
  expect(User.find_by(email: 'carl@test.com').permissions).to include(:admin)
end
```

Seed tests (or however we want to call them) are different than regular
specs/tests we run them once as a part of the reseed process therefore
there is a wider window for not spotting some cached instance variable or
something. I would rather let my `rake db:seed` task to take 2 seconds
more than I would spend 20 minutes fixing db:seeds over weekend.
Plus are just running them once or twice a week.

Like I said this works for my requirement but I would recommend to have a look on 
[this SO question](http://stackoverflow.com/questions/6004057/w-rspec-how-to-seed-the-database-on-load)
for more suggestions. Especially if you need to seed database before
running specs one interesting ide is this:

```ruby
# spec/spec_helper.rb
Spec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    Rails.application.load_seed # loading seeds
  end
end
```

## Word on Gemfile

I agree that it's stupid to have `RSpec` exposed for every enviroment 
(production or staging env may not need them). Solution for this is easy: 

```ruby
# Gemfile

group :development, :test, :staging, :demo do
  gem 'rspec-rails', require: false
end
```

...or if we want to be more hardcore

```ruby
# Gemfile

group :demo do
  gem 'rspec-expectations', require: false
end

group :development, :test do
  gem 'rspec-rails', require: false
end
```


## RSpec in IRB console

If you look for a way how to load RSpec in irb:

```ruby
require 'rspec/expectations'
include RSpec::Matchers
1.should eq 1
# => true
```

Published: 2014-06-02

Keywords: Rails 4, Ruby 2.1.2,  RSpec, specs, seeds, database, seed, irb rspec

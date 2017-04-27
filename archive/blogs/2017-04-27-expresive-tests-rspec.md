# Expressive tests with RSpec - part 1: Describe your tests properly

Ruby gem RSpec is powerful library for testing. Reason why many
developers chose it over other testing tools is it's expressiveness.

Now the thing is that many Ruby developers that are using RSpec on daily base
for several years care about ensuring the test represents logical values but don't quite bother
with how their test express their intention. This apply for those that
are not doing TDD/BDD  but even for those that do.

I've decided to create series of articles titled "Expressive tests with RSpec"
where I will try to show you how you can make your tests much cleaner,
better to read and most importantly better to maintain.

## Our Example

> **note:** Example will be Ruby on Rails due to it's popularity based but everything I
> describe here apply to plain Ruby or any other framework of your
> choice.

So let say we are selling a product `Package` that belongs to a `Company`
or a `User`. In Ruby on Rails world we would map this relationship
like:

```ruby
class Package < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
end

# packages table:
# | id | owner_id | owner_type |

class User < ActiveRecord::Base
  has_many :packages
end

class Company < ActiveRecord::Base
  has_many :packages
end
```

Now one day you will have to send notification to admin when any company buys a
`Company` package. In order to DRY the code you implement method that will
tell you this information:

```ruby

class Package < ActiveRecord::Base
  # ...

  def company_owned?
    owner_type == Company.to_s
  end
end
```

Now how would you write test for this method ?

```ruby
require 'rails_helper'

RSpec.describe Package do
  # ????
end
```

## How not to do it.

So some developers would write the test like this:


```ruby
require 'rails_helper'

RSpec.describe Package do
  it "should return true when it's owned by company" do
    package = Package.new(owner: Company.new)
    expect(package.company_owned?).to eq true
  end

  it "should return false when it's owned by user" do
    package = Package.new(owner: User.new)
    expect(package.company_owned?).to eq false
  end
end
```

Now argument would be that it's simple, it represent code logic and it's
expresive enough for this simple case.

Now I'm fan of not overkilling the code when it's not needed, but to me
this is nothing to do with simplicity but rather developer not caring /
not focusing on test maintainability at all.

Let me try to show you how I would write this:


## Describing intention

First of all we need to realize that in this test we are describing
particular object and it's state / behavior. We could just say something like:


```ruby
require 'rails_helper'

RSpec.describe Package do
  let(:package) { Package.new(owner: owner) }

  # ????
end
```

> Don't worry about the `owner` yet we will get to that.

But the thing is we are locking our test code from first few lines to
name implementation. Most of times developer think they know what
"names" the objects are as they are replicating domain logic. But too
often they realize in middle of implementation  that maybe the name of the
class was not that great after all.

At that point what would the responsible developer do is to rename the Class and all the object
occurences. But lot of developers will just say "what the hell it's
close enough I'm not going to waste time renaming everything" and carry on with the misleading object names introducing
terrible burden on the rest of the team from day one implementation.

RSpec provides a way to get around this with `described_class` and `subject`.


```ruby
require 'rails_helper'

RSpec.describe Package do
  subject { described_class.new(owner: owner) }

  # ????
end
```

> **note 1**: think about `subject` as if you were a scientist and you
> are describing "subject of study" or "subject of an experiment"

> **note 2**: When you `RSpec.describe` a class, by default
> `subject` will be equal to instance of a class with no args e.g.
> `Package.new()`. That's why sometimes you may see RSpec code that
> calls `subject` without anywhere defining the block.

> **note 3** Yes we could use [FactoryGirl gem]( @todo ) instead of `describe_class.new` but that's not
> the point I'm trying to make here. Bare with me please.

As a second step lets express that we are describing a particular method
/ interface :

```ruby
require 'rails_helper'

RSpec.describe Package do
  subject { described_class.new(owner: owner) }

  describe '#company_owned?' do
    # ????
  end
end
```

Now lets express that we want to describe particular contexts of this
method, When owner is a Company and when User:


```ruby
require 'rails_helper'

RSpec.describe Package do
  subject { described_class.new(owner: owner) }

  describe '#company_owned?' do
    context 'when owned by User' do
      let(:owner) { User.new }

      # ????
    end

    context 'when owned by Company' do
      let(:owner) { Company.new }

      # ????
    end
  end
end
```

> Developers treat `context` and `describe` as aliases and really they are
> but only on code level. But try to read the code as document. We are: *describing*
> `Package`object *describing* `company_owned?` method  in *context* of owned being
> User and *context* of owner being Company.


## Actual test

Now we finally getting to the actual test implementation. Now the
simplest thing to do would be to write:


```ruby
require 'rails_helper'

RSpec.describe Package do
  subject { described_class.new(owner: owner) }

  describe '#company_owned?' do
    context 'when owned by User' do
      let(:owner) { User.new }

      it do
        expect(subject.company_owned?).to eq false
      end
    end

    context 'when owned by Company' do
      let(:owner) { Company.new }

      it do
        expect(subject.company_owned?).to eq true
      end
    end
  end
end
```

...but we are repeating code here.

Let's try to wrap the
`subject.company_owned?` into another `let` block called `result` (as if
result of the test)


```ruby
require 'rails_helper'

RSpec.describe Package do
  subject { described_class.new(owner: owner) }

  describe '#company_owned?' do
    let(:result) { subject.company_owned? }

    context 'when owned by User' do
      let(:owner) { User.new }

      it do
        expect(result).to eq false
      end
    end

    context 'when owned by Company' do
      let(:owner) { Company.new }

      it do
        expect(result).to eq true
      end
    end
  end
end
```


Some of you may say that it was just two lines of code "no big deal". Why would I
introduce "another" line of code to fix such a trivial duplication. Well
the argument here is the same as with the use of `describe_class` and
`subject`. If a developer decide to rename the method he should have as
little work to do as possible no matter if it's one call or hundred
calls otherwise developers will say "what the hell it's close enough,
I'm not going to rewrite it".


Ok moving to next part. Our test works, it well comply with the `Given When Then` approach and it's D.R.Y. (Don't repeat yourself)

Lets try to read the test as a document again.

```
Package company_owned? when owned by User should eq to false.

Package company_owned? when owned by Company should eq to true.
```

Seems nice. But one thing I encourage everyone to do is to spend as much
time as possible reading RSpec documentation. There are lot of nice
features RSpec provide that helps you express yous tests.

One of them is that RSpec generates matchers for given object question mark methods. So in our case
`subject.company_owned?` can be called matched as `expect(subject).to be_company_owned`


```ruby
require 'rails_helper'

RSpec.describe Package do
  subject { described_class.new(owner: owner) }

  describe '#company_owned?' do
    context 'when owned by User' do
      let(:owner) { User.new }

      it do
        expect(subject).not_to be_company_owned
      end
    end

    context 'when owned by Company' do
      let(:owner) { Company.new }

      it do
        expect(subject).to be_company_owned
      end
    end
  end
end
```

# Expressive tests with RSpec - part 1: Describe your tests properly

Ruby gem RSpec is powerful library for testing. Reason why many
developers choose it over other testing tools is it's expressiveness.

Now the thing is that many Ruby developers that are using RSpec on daily base
care just about ensuring the test represents logical values but don't quite bother
with how tests they write express their intention. This apply for both those that
don't bother doing TDD/BDD but even for those that do; for junior
developer but also developers using the library several years.

I've decided to create series of articles titled "Expressive tests with RSpec"
where I will try to show you how you can make your tests much cleaner,
better to read and most importantly better to maintain.

> Tests better to maintain ? Why ? ...tests, like any other code needs
> to be kept clean and maintained otherwise (paradoxically) developers spend more time
> fixing them. Tests are like kitchen equipment. Although you care just
> about preparing the delicious food, if you don't clean your equipment on regular
> bases, preparing next meal will be harder and final product will stink after old
> burned pieces.

## Our Example

> **note:** Example will be Ruby on Rails based due to it's popularity but everything I
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

Now one day a requirement comes from your boss to send notification to admin when any company buys a
`Company` package. In order to DRY the code you implement method that will
tell you this information:

```ruby

class Package < ActiveRecord::Base
  # ...

  def company_owned?
    owner.company?
  end
end

class Company < ActiveRecord::Base
  # ...
  def company?
    true
  end
end

class User < ActiveRecord::Base
  # ...
  def company?
    false
  end
end
```

Now how would you write test for method `Package#company_owned?` ?

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

> Let's ignore the fact that we could  test `Company#company?` and
> `User#company?` separately and then just pass dummy object to
> `Package` responding to common interface. I just want to show you
> point of expressing intention not to discuss polymorphism testing.

Now argument for this code style would be that it's simple, just few lines,
it represent code logic without problem and it's
expresive enough for this simple case. No need to spend more time on
this test and move to next one.

Now I'm fan of not overkilling the code when it's not needed, but to me
this is nothing to do with simplicity but rather developer 
not focusing on test maintainability at all.

Let me try to show you how I would approach writing the test around this:

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

> Don't worry yet about the value of `owner`  we will get to that.

But the thing is we are locking our test code from first few lines to
name implementation. Most of times developer think they know what
"names" the objects are as they are replicating domain logic. But too
often they realize in middle of implementation  that maybe the name of the
class was not that great after all.

At that point what would the responsible developer do is to rename the Class and all the object occurrence.
But lot of developers will just say "What the heck, it's
close enough I'm not going to waste time renaming everything" and carry on with the misleading object names introducing
terrible burden on the rest of the team from day one of the implementation.

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

> **note 3** Yes we could use [FactoryGirl gem](https://github.com/thoughtbot/factory_girl) instead of `describe_class.new` but that's not
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
method, When owner is a Company and when owner is a User:


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

Developers treat `context` and `describe` as aliases which they really are
but only on code level. But try to read the code as document. We are: *describing*
`Package` object *describing* `company_owned?` method  in *context* of owned being
User and *context* of owner being Company.

The way I see it is that `context` is a situation, `describe` is definition (as definition of whats the test about)


## Assertion

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
result of the method)


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
calls otherwise developers will say "what the heck method name is close enough,
I'm not going to rewrite it".


## RSpec sugar

Our test works, it well comply with the `Given When Then` approach and it's D.R.Y. (Don't repeat yourself)

Lets try to read the test as a document again.

```
Package company_owned? when owned by User should eq to false.

Package company_owned? when owned by Company should eq to true.
```

Seems nice. But one thing I encourage everyone to do is to spend as much
time as possible reading RSpec documentation. There are lot of nice
features RSpec provide that helps you express yous tests. Some of them I
wrote about in the past articles ( [RSpec be_within_matcher](http://www.eq8.eu/blogs/27-rspec-be_within-matcher), [RSpec JSON API testing](http://www.eq8.eu/blogs/30-pure-rspec-json-api-testing) )
and more I will try to describe in the future articles.

One of them is that RSpec features is that it provides matchers for given object question mark methods. So in our case
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

Reading the test now literally is like:

```
Package company_owned? when owned by User, package is not company_owned.

Package company_owned? when owned by Company, package is company_owned.
```

Now the argument would be that we could just remove the extra describe
blocks and have the test simplified as this:


```ruby
require 'rails_helper'

RSpec.describe Package do
  subject { described_class.new(owner: owner) }

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
```

Honestly I don't mind I personally like to keep the method description
block in place as it helps to keep stuff together. But there are cases
when I write code like this, like Policy Classes:


```ruby
require 'rails_helper'

class UserPolicy
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def able_to_edit_own_profile?
    user.activated? || user.admin?
  end

  def able_to_access_admin_section?
    user.admin?
  end

  # ...
end

RSpec.describe UserPolicy do
  subject { described_class.new(user) }

  context "when admin" do
    let(:user) { User.new(role: 'admin' }

    it { expect(subject).to be_able_to_edit_own_profile }
    it { expect(subject).to be_able_to_access_admin_section }
  end

  context "when regular user" do
    let(:user) { User.new(activated: activated }
    let(:activated) { false }

    it { expect(subject).not_to be_able_to_edit_own_profile }
    it { expect(subject).not_to be_able_to_access_admin_section }


    context "when profile activated" do
      let(:activated) { true }

      it { expect(subject).to be_able_to_edit_own_profile }
      it { expect(subject).not_to be_able_to_access_admin_section }
    end
  end

  # ...
end
```

Now in this case you can see that it make sense not to describe method
by method base but rather contextual situations. This is due to nature
of policy object responsibility: you ask it a
questions about what user can do in given situation.

So even if I had method `contactable_user_ids` that would return users
ids that given type of user can contact, I may implement it as part of
these contexts to some extend. Once I would have several type of users
than only some types can contact, it would not make much sense to
introduce so many contexts to existing policy methods so I would just
write own describe block for this complex method.

```ruby
RSpec.describe UserPolicy do
  subject { described_class.new(user) }

  context "when admin" do
    # ...
  end

  context "when regular user" do
    # ...

    context "when profile activated" do
       # ...
    end
  end

  describe '#contactable_user_ids' do
    context "when admin" do
       # ...
    end

    context "when activated user" do
       context "that has a friend" do
         # ...
       end

      context "that has no friends but people want to be contacted by strangers" do
         # ...
       end
    end
  end
end
```

But models (especially Rails models) have way too many responsibilities
on their shoulders. It would be really time consuming and complex to
write every methods for every context. It always depends on the value
you are trying to get from the test not on following principles blindly.
Just keep your tests expressive.


## Conclusion

In this article I've just shown you how I would test the "state" of an
object, but what about testing "functionality" ? What if you need to
share behavior between test? What about mocks/doubles ? ...more articles
coming soon ;)

As from this article please take this advices: 

* tests are important part of code base, keep them clean and expressive
* you should be able to read descriptions and contexts as a story book,
  not just put entire definition of the test to `it` definition
* keep tests dry
* use `subject` and `describe_class` or anything that save you time
  renaming class/method name, but at the same time try not to overkill
  it (e.g. some metaprogramning woodoo is rarely helpful in a test).

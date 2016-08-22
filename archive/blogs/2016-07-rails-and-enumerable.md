# Rails and Enumerable 

Pretty simple and really useful. Of course I've wrote the tests and code on
scenarios with TDD approach, but as this class being just an extension of `Enumerable`
I was too ignorant to include tests for
degenerate/predictable cases like testing `empty?` or `blank?`.

You see in plain Ruby when you call

```ruby
[].empty?
# => true

[].blank?
NoMethodError: undefined method `blank?' for []:Array
```

... methods like `#blank?` don't exist

But Rails extends `Object` with:

```ruby
  # rails/activesupport/lib/active_support/core_ext/object/blank.rb
  class Object
    # ....

    def blank?
      respond_to?(:empty?) ? !!empty? : !self
    end

    # ....
  end
```

...and extends `Array` and `Hash` with: `alias_method :blank?, :empty?` ([source](https://github.com/rails/rails/blob/a476020567a47f5fbec3629707d5bf31b400a284/activesupport/lib/active_support/core_ext/object/blank.rb))

Therefore in Ruby on Rails you are able to do:

```ruby
[].empty?
# => true

[].blank?
# => true

['hi'].blank?
# => false

'any other object'.blank?
# => false
```

As it turns out there was bit of logic and  we were calling `[m].blank?`.
That was replaced with the new: `MembershipCollection.new([m]).blank?` and that `blank?`
was not implemented.

In order to fix this, your collection class needs to delegate `empty?`
instance method to the original collection:

```
class Membership
  class MembershipCollection
    include Enumerable

    delegate :empty?, :each, to: :@members

  # ...
```

Here is the entire test for the working scenarios:

```ruby
require 'rspec'

RSpec.describe Membership::MembershipCollection do
  subject { described_class.new(memberships) }
  let(:free_membership) { Membership.new.tap { |m| m.type = 'free'} }
  let(:paid_membership) { Membership.new.tap { |m| m.type = 'paid'} }

  context 'when no memberships' do
    let(:memberships) { [] }

    it { expect(subject).to be_blank }
    it { expect(subject).to be_empty }
    it { expect(subject.free).to be_empty }
    it { expect(subject.paid).to be_empty }
  end

  context 'when free memberships' do
    let(:memberships) { [free_membership] }

    it { expect(subject).not_to be_blank }
    it { expect(subject).not_to be_empty }
    it { expect(subject.free).to eq([free_membership]) }
    it { expect(subject.paid).to be_empty }
  end

  context 'when paid memberships' do
    let(:memberships) { [paid_membership] }

    it { expect(subject).not_to be_blank }
    it { expect(subject).not_to be_empty }
    it { expect(subject.free).to be_empty }
    it { expect(subject.paid).to eq([paid_membership]) }
  end
end
```

We have pretty decent test coverage around entire app so this problem
was spotted pretty early, but still I was pretty disappointed of myself
as I was blindly focusing on plain ruby 


Moral of the story for me is that when Rails don't just focuse

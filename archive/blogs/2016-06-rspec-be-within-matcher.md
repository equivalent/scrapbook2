# RSpec be_within matcher

[![Open Thanks](https://thawing-falls-79026.herokuapp.com/images/thanks-1.svg)](https://thawing-falls-79026.herokuapp.com/r/locyfspz)

> You can find entire code example in [this gits](https://gist.github.com/equivalent/faa2928e93056842e62c8d00f15b48ba)

RSpec has some really nifty built in matchers. In this article we will
have a look at `be_within` matcher.

The syntax is pretty simple

```ruby
value          = 10.0001
expected_value = 10.0001
delta          =  0.0001

expect(value).to be_within(delta).of(expected_value)
```

The most common example where to use `be_within` is when comparing
floating point values if their are in a range/delta of acceptance
(e.g. if you returning float value from database, Math calculations, ...)

```ruby
require 'rspec'

class Foo
  def float_range_example
    33 * 5 * Math::PI
  end
end

RSpec.describe(Foo) do
  subject { described_class.new }

  describe '#float_range_example' do
    it do
      expect(subject.float_range_example).to be_within(0.01).of(518.3627878423158)
    end
  end
end
```

But these matchers can be also used to compare delta of Time values.

```ruby
require 'rspec'
require 'time'

class Foo
  # ...

  def time_range
    Time.now
  end
end

RSpec.describe(Foo) do
  # ...

  describe '#time_range' do
    context 'in pure Ruby' do
      it do
        expect(subject.time_range).to be_within(2).of(Time.now)
      end
    end
  end
end
```

If you're using `ActiveSupport` (part of a Ruby on Rails framework) you
may want to pass `2.secconds` instead for better readability:

```ruby
require 'rspec'
require 'active_support/time'

RSpec.describe(Foo) do
  # ...

  describe '#time_range' do
    # ...

    context 'in Rails' do
      it do
        expect(subject.time_range).to be_within(2.seconds).of(Time.now)
      end
    end
  end
end
```

> Delta value (range of acceptance) is really up to you to decide but 
> I had once a situation where my laptop had SSD drive and coworkers laptop
> had HDD. When he run his test suite some of the tests were failing
> just because of too tight delta value on Time.now

Many of you may be already familiar with the fact that RSpec 3 `match` matcher
can compare similarities in a Hash. Did you know that you can pass other
matchers to it, including regular expressions and `be_within` matchers?

```ruby
class Foo
  # ...

  def hash_with_range_value
    {
      id: 1,
      title: 'SPS J.Murgasa',
      city: "Banska Bystrica",
      created_at: Time.now
    }
  end
end

RSpec.describe(Foo) do
  # ...

  describe '#hash_with_range_value' do
    it do
      expect(subject.hash_with_range_value).to match({
        id: 1,
        title: 'SPS J.Murgasa',
        city: /[bB]an/,
        created_at: be_within(1).of(Time.now)
      })
    end
  end
end
```

If this test would fail you would get helpful output similar to this:

```bash
Failures:

  1) Foo#hash_with_range_value should match {:id=>1, :created_at=>(be
within 1 of 2016-06-29 19:48:21 +0100), :city=>/[bB]an/}
     Failure/Error: expect(subject.hash_with_range_value).to match({
       expected {:id=>1, :created_at=>2016-06-29 19:38:21.681774449
+0100, :city=>"Banska Bystrica"} to match {:id=>1, :created_at=>(be
within 1 of 2016-06-29 19:48:21 +0100), :city=>/[bB]an/}
       Diff:
       @@ -1,4 +1,4 @@
       -:city => /[bB]an/,
       -:created_at => (be within 1 of 2016-06-29 19:48:21 +0100),
       +:city => "Banska Bystrica",
       +:created_at => 2016-06-29 19:38:21.681774449 +0100,
        :id => 1,
```

Pretty readable !

If you comparing values in Array you can do:


```ruby
class Foo
  # ...

  def array_with_range_values
    [Time.now, Time.now.midnight, Time.now.midday, 3.days.ago]
  end
end

RSpec.describe(Foo) do
  # ...

  describe '#array_with_range_values' do
    it do
      expect(subject.array_with_range_values).to match_array([
        be_within(2.seconds).of(Time.now),
        be_within(2.seconds).of(Time.now.midnight),
        be_within(2.seconds).of(Time.now.midday),
        be_within(2.seconds).of(Time.now - 3.days)
      ])
    end
  end
end
```

Resouces used in this article:

* Ruby lang v 2.3.0
* [RSpec](https://github.com/rspec/rspec) v 3.4
* https://www.relishapp.com/rspec/rspec-expectations/v/2-8/docs/built-in-matchers/be-within-matcher
* https://gist.github.com/equivalent/faa2928e93056842e62c8d00f15b48ba


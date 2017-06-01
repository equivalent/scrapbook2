# Tell ActiveJob to perform_later as perform_now in Test or Spec

Rails[ActiveJob](http://edgeguides.rubyonrails.org/active_job_basics.html)

Let say you have `perform_later` job that is calling another
`perform_later` job and you want to test the end result.

```ruby
class Job1 < AciveJob::Base
  def perform(foo:)
    bar = "#{foo}bar"
    Job2.perform_late(bar: bar)
  end
end

class Job2 < AciveJob::Base
  def perform(bar:)
    Httparty.post("http://myserver", bar)
  end
end

require 'spec_helper'
RSpec.describe Job1 do
  it do
    expect(Httparty).to receive(:post).with("http://myserver", "mybar")
    Job1.new.perform("my")
  end
end
```

Even if you set the queuing adapter to be`ActiveJob::Base.queue_adapter = :test`
the second call may not be executed as ActiveJob is holding second call
for assertion tests

> note: there is alse `ActiveJob::Base.queue_adapter = :inline` that may
> solve the issue

What you can do is wrap the call in build in `ActiveJob::TestHelper` module
method `perform_enqueued_jobs` block:

* http://api.rubyonrails.org/v4.2/classes/ActiveJob/TestHelper.html#method-i-perform_enqueued_jobs

```ruby
require 'spec_helper'
RSpec.describe Job1 do
  include ActiveJob::TestHelper

  it do
    perform_enqueued_jobs do
      Job1.new.perform("my")
    end
  end
end
```

Or if you don't want to polute your tests with unecesarry methods:


```ruby
require 'spec_helper'

module MyTest
  class Jobs
    include ActiveJob::TestHelper
  end

  def self.jobs
    @jobs ||= Jobs.new
  end
end

RSpec.describe Job1 do
  it do
    MyTest.jobs.perform_enqueued_jobs do
      Job1.new.perform("my")
    end
  end
end
```

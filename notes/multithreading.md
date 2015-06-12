### Race Condition

[jim weirinch talk at 2008 ruby conf](https://www.youtube.com/watch?v=fK-N_VxdW7g) 15:00 

```ruby
require 'thread'

class Account
  attr_reader :amount

  def initialize(init_amount)
    @amount = init_amount
  end

  def credit(amount)
    @amount += amount
  end
end

THREADS = (ARGV[0] || 10).to_i
ITERATE = 1000000
TOTAL = THREADS * ITERATE

account = Account.new(0)

threads = (0...THREADS).map {
  Thread.new do
    ITERATE.times do
      account.credit(1)
    end
  end
}
```

multithred is executing in microsteps, in some casses some micro steps
will get in front of other (looping through account balance)


To Avoid race condition you want to disable context switching (for
related piece of code) before account loop and reenable it when done
(Mutex)

```ruby
require 'therad'
mutex = Mutex.new

mutex.synchronize do 
  account.credit(1)
end
```

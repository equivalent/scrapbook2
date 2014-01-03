Custom DSL mock helper for adding permissions


```ruby
# spec/support/policy_permission_mock.rb

class PolicyPermissionsMock
  attr_reader :tld_id, :permissions

  def self.build(&block)
    policy_mock = new
    delegator = BlockAcceptanceDelegator.new(policy_mock)
    delegator.evaluate(&block)
    policy_mock
  end

  def initialize
    @permissions = []
  end

  def add(permission_type, tld_id = nil)
    @permissions << FactoryGirl.build(permission_type, tld_id: tld_id)
  end

  class BlockAcceptanceDelegator < SimpleDelegator
    def add(*args)
      __getobj__.add(*args)
    end

    def evaluate(&block)
      @self_before_instance_eval = eval "self", block.binding
      instance_eval(&block)
    end

    def method_missing(method, *args, &block)
      @self_before_instance_eval.send method, *args, &block
    end
  end
end

module PolicyPermissionsMockHelper
  def policy_permissions_mock(&block)
    PolicyPermissionsMock.build(&block).permissions
  end
end
```

Source of information: 

* http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
* http://blog.joecorcoran.co.uk/2013/09/04/simple-pattern-ruby-dsl/?utm_source=rubyweekly&utm_medium=email

```ruby

# rspec spec/model/post_test.rb
require 'minitest/autorun'
require_relative '../../app/models/post'

# mock
@blog=MiniTest::Mock.new

# Avdi sometimes mock like this
@blog = Object.new
```
 

# setup gem
 
### run just one test file

`ruby -Itest spec/**/*_spec.rb`
 
### Rakefile

`vim ./Rakefile`

```ruby
require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task default: :test
```

### test folder

`mkdir ./test`


# rspec like matchers

| Assertion              | Examples                                                |   
| ---------------------- | ------------------------------------------------------- | 
| must_be                | `list.size.must_be :==, 0`                              |   
| must_be_close_to       | `subject.size.must_be_close_to 1,1`                     |   
| must_be_empty          | `list.must_be_empty`                                    |   
| must_be_instance_of    | `list.must_be_instance_of Array`                        |   
| must_be_kind_of        | `list.must_be_kind_of Enumerable`                       |   
| must_be_nil            | `list.first.must_be_nil`                                |   
| must_be_same_as        | `subject.must_be_same_as subject`                       |   
| must_be_silent         | `proc { "no stdout or stderr" }.must_be_silent`         |   
| must_be_within_epsilon | `subject.size.must_be_within_epsilon 1,1`               |   
| must_equal             | `subject.size.must_equal 2`                             |   
| must_include           | `subject.must_include "skinny jeans"`                   |   
| must_match             | `subject.first.must_match /silly/`                      |   
| must_output            | `proc { print "#{subject.size}!" }.must_output "2!"`    |   
| must_respond_to        | `subject.must_respond_to :count`                        |   
| must_raise             | `proc { subject.foo }.must_raise NoMethodError`         |   
| must_send              | `subject.must_send [subject, :values_at, 0]`            |   
| must_throw             | `proc { throw :done if subject.any? }.must_throw :done` | 


stolen from: http://mattsears.com/articles/2011/12/10/minitest-quick-reference

# Testing for exceptions with MiniTest

    proc {code block that will actually raise that exception}.must_raise(expectedException)
    proc {Integer.fizzbuzz}.must_raise(NoMethodError)
   
source http://cczona.com/blog/2011/10/asserting-exceptions-with-minitest/

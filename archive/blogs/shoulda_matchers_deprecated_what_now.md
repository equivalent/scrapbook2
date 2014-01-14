# Shoulda matchers depricated. Now what ?

Referring to:

* https://github.com/thoughtbot/shoulda-matchers/issues/186
* https://github.com/thoughtbot/shoulda-matchers/issues/252 
* [Thoughtbots article related to v 2.0 matcher deprecations](http://robots.thoughtbot.com/post/47031676783/shoulda-matchers-2-0)

[shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers) have removed several matchers:


*     assign_to
*     respond_with_content_type
*     query_the_database
*     validate_format_of
*     have_sent_email
*     strong_parameters_matcher
*     delegate_method

I was personally using `assign_to` and `respond_with_content_type` in project I was working on. Thoughtbot team suggest to use integration tests instead of these two. While I agree with this work-flow sometimes projects don't have enough resources or time to implement them.

##  `respond_with_content_type` matcher fix

simplest way is to just replace any occurrence of `respond_with_content_type` with : 
    
```ruby
# spec/controllers/users_controller_spec.rb
describe UsersController do
  before{ get :index, :format => :xlsx }
  it 'response should be excel format' do
    response.content_type.to_s.should eq Mime::Type.lookup_by_extension(:xlsx).to_s
  end
end
```

if you want a proper matcher than:

```ruby
# spec/support/matchers/respond_with_content_type_matchers.rb
RSpec::Matchers.define :respond_with_content_type do |ability|
  match do |controller|
    expected.each do |format|  # for some reason formats are in array
      controller.response.content_type.to_s.should eq Mime::Type.lookup_by_extension(format.to_sym).to_s
    end
  end

  failure_message_for_should do |actual|
    "expected response with content type #{actual.to_sym}"
  end

  failure_message_for_should_not do |actual|
    "expected response not to be with content type #{actual.to_sym}"
  end
end
```

```ruby
# spec/spec_helper.rb
#...
#ensure support dir is loaded
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}  
#...
```

I agree with Thoughtbot on one thing: I don't see that much value in this matcher. That's why I don't see point extracting it into gem...maybe in future.

##  `assign_to` matcher fix

There is already a gem [shoulda-kept-assign-to](https://github.com/tinfoil/shoulda-kept-assign-to). It's really lightweight (just one module) so you don't have to be worried about extra crap slowing your code. 

So just:

```ruby
group :test do
  gem "shoulda-kept-assign-to"
end
```

...and business as usual


related links:

* http://stackoverflow.com/questions/18760257/how-to-test-respond-with-content-type-when-its-depricated-in-shoulda-matches-2/18760258#18760258

published: 2013-09-12


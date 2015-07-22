# how to include Capybara RSpec matchers in RSpec

let say you want to use `have_content` and `have_selector` in spec 


```ruby
# Gemfile
gem 'capybara'
gem 'rspec'
```

```ruby
# spec/spec_helper.rb
#...
require 'capybara/rspec'
#...
```

```ruby
require 'spec_helper'

RSpec.describe MyPresenter do
  include Capybara::RSpecMatchers
  
  it do 
    expect("<b>abc</b>").to have_selector("b")
  end
end
```

# change Rack Test default host

If you're using [Rack Test](https://github.com/brynary/rack-test) to test requests on your Sinatra application
you will notice that by default the host is `example.org`.

you can change this like this:

```ruby
# spec/spec_helper.rb
def app
  MySinatraOrRackApp
end

module Rack
  module Test
    module Methods
      def build_rack_mock_session
        Rack::MockSession.new(app, 'api.myapp.com')
      end
    end
  end
end

# this has to be done before you do  `include Rack::Test::Methods`
```


note: 
Rack Test is the lib that is repsonsible for request test, so when you do
`post('/events')`, `get('/', token: 123)`, ...

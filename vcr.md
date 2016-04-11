# VCR  gem


## matchers

http://railsware.com/blog/2013/10/03/custom-vcr-matchers-for-dealing-with-mutable-http-requests/

```ruby

# default is [:method, :uri]
context '', :vcr, :match_requests_on => [:method, :path, :body] do
  it 'Save ProvisionalUpload' do
    # ...
  end
end



```


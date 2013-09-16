### [Builder pattern](http://en.wikipedia.org/wiki/Builder_pattern)

Instead of using numerous constructors, the builder pattern uses another object, a builder, that receives each initialization parameter step by step and then returns the resulting constructed object at once.

Example:

```ruby
Config.new do
  files 'foo.bar', 'baz/qux.quux'
  candies 'chocolate'
end
```

links: http://blog.joecorcoran.co.uk/2013/09/04/simple-pattern-ruby-dsl/?utm_source=rubyweekly&utm_medium=email, http://en.wikipedia.org/wiki/Builder_pattern, 

# Troubles with reqexp encoding

Today friend of my shown me problem that he encounter while he was
working on his [regexp-examples
gem](https://github.com/tom-lord/regexp-examples)


```ruby
'<'  =~ /[[:punct:]]/
# => nil

60.chr  # =>  '>'
60.chr  =~ /[[:punct:]]/
# => 0

60.chr == '<'
# => true

60.chr === '<'
# => true
```

It took him a while to figure out what was the problem

```
'<'.encoding
# => #<Encoding:UTF-8>

60.chr.encoding
# => #<Encoding:US-ASCII>
```

solution :

```
60.chr.encode('UTF-8') =~ /[[:punct:]]/
# => nil
```


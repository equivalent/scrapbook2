# Converting model names to strings

[ActiveSupport::Inflector](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-classify)  

```ruby
'editable_document'.classify
# => "EditableDocument"
```

```ruby
'EditableDocument'.constantize
# => EditableDocument (class)
```

```ruby
'EditableDocument'.underscore
# => editable_document
```

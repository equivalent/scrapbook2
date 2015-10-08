


```haml
= simple_form_for :custom_form,
  url: root_path,
  method: 'get',
  html: { id: 'fetch_custom_form',
  :'data-remote' => true } do |f|
  = f.input :validation_type_id, collection: @application.tld.validation_types
  
```

# selected via lambda

```haml
= f.input :application_strategy,
  required: true,
  collection: Strategy.strategies_for_view,
  selected: lambda { |option| @user.application_strategy == option[0] }
```

# simple form for plain ruby class

```ruby
class User
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_accessor :name, age

  def persisted?
    false
  end
end
```

```haml
= simple_for_for User.new do |f|
  = f.input :name
  = f.input :age
```

# bootstrap 3 

https://github.com/rafaelfranca/simple_form-bootstrap

# extend on load

```ruby

module DeviseSecurityExtension
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include DeviseSecurityExtension::Controllers::Helpers
    end 
    ActionDispatch::Callbacks.to_prepare do
      DeviseSecurityExtension::Patches.apply
    end 
  end 
end
```


# params 

rails 4

```
@params =  ActionController::Parameters.new(abc: 123)
```

rails 3

```
HashWithIndifferentAccess.new
````

# How to render previous view

```ruby
Class MyController < ActionController::Base

  def update

    render Rails.application.routes.recognize_path(request.referer)[:controller] # => "my_controlller"
    render Rails.application.routes.recognize_path(request.referer)[:action] # => "edit"

  end
end
```

# Rails native authentication via header

````
class ApiController < ApplicationController
  def authenticate_api_user!
    authenticate_or_request_with_http_token do |token, options|
      @current_user = User.where(authentication_token: token).first
    end 
  end 
end

curl -H "Authorization: Token token=bbbmytokenbbbb" 
```



# reveal all controller callbacks / filters

inside pry (where self is controllec)

```
_process_action_callbacks.map(&:filter)
```

http://pivotallabs.com/revealing-the-actioncontroller-callback-filter-chain/

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

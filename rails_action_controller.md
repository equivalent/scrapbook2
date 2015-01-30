
# How to render previous view

```ruby
Class MyController < ActionController::Base

  def update

    render Rails.application.routes.recognize_path(request.referer)[:controller] # => "my_controlller"
    render Rails.application.routes.recognize_path(request.referer)[:action] # => "edit"

  end
end
```

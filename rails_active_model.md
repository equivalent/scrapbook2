# validation & custom validators

*simple one function solution*

```ruby
class User < ActiveRecord::Base
  validate :check_photo_dimensions

  def check_photo_dimensions
    if photo_width < 480
      errors.add :photo, "Width of photo is too small." 
    end
  end
end
```

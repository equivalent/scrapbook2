# CarrierWave File Uploader Scrapbook

in All examples I'll be suspecting that I'm dealing with a model with mounted Uploader

```ruby
# app/models/document.rb
class User < ActiveRecord::Base
  mount_uploader Avatar
    
  # ...
end

```

## Tell my specs/tests to use different root path

I don't want my test to store files to `~/projects/my_project/public/uploads` folder but
rather `~/projects/my_project/tmp/uploads` folder


```ruby
# app/uploaders/avatara_uploader.rb
class AvatarUploader < CarrierWave::Uploader::Base
  storage :file
  
  # ...
  def root
    Rails.env.test? ? "#{Rails.root.to_s}/tmp/" : super
  end
  # ...
end
```

all other settings (like `store_dir`) will stay unchanged 

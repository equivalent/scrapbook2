# CarrierWave File Uploader Scrapbook



## testing with RSpec 

in All examples I'll be suspecting that I'm dealing with a model with mounted Uploader

```ruby
# app/models/document.rb
class User < ActiveRecord::Base
  mount_uploader Avatar
    
  # ...
end

```


### How to mock/stub file in model that is using  CarrierWave uploader

```ruby
require 'spec_helper'
describe User do
 
  let(:upload) do
    ActionDispatch::Http::UploadedFile.new({
      :filename => 'blank_pdf.pdf',
      :content_type => 'pdf',
      :tempfile => File.new("#{Rails.root}/spec/factories/uploads/blank_pdf.pdf")
    })
  end
  
  it do
    user = User.new(avatar: upload)
    user.avatar.file.exists?  #=>true
  end
end
```

relevant links:

* http://stackoverflow.com/questions/4511586/rails-functional-test-case-and-uploading-files-to-actiondispatchhttpuploadfi


rails: 3.2.14

published: 16.09.2013


### Tell my specs/tests to use different root path

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

rails: 3.2.14

published: 16.09.2013

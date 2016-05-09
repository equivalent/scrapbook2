# CarrierWave File Uploader Scrapbook

## testing upload file

```
 include Rack::Test::Methods

post "/upload/", "attachement" => Rack::Test::UploadedFile.new("path/to/file.ext", "mime/type")
```

## Store / Retrieve without model

```ruby
class ReportUploader < CarrierWave::Uploader::Base
  storage(Rails.configuration.carrierwave_storage_type)
  permissions 0644

  attr_accessor :explicit_filename # I'm storing Tempfile => the file name is altered with randomnes
                                   # this way I'll explicitly name the file when storing

  def store_dir
    "uploads/reports/"
  end

  def filename
    explicit_filename || raise('you need to explicitly pass file name')
  end
end

RSpec.describe 'store & retriev' do

  let(:report_file_name) { 'test.csv' }

  describe "store" do
    it do
      tmp_file = Tempfile.new(report_file_name)
      tmp_file.write('test, other test, bla bla')
      tmp_file.close
      @uploader = ReportUploader.new
      @uploader.explicit_filename = report_file_name
      @uploader.store!(tmp_file)  # or File.open(tmp_file.path)
      # ...
      tmp_file.unlink # rm tmp file
    end
  end
  
  describe "retriew" do
    it do 
      uploader = ReportUploader.new
      uploader.retrieve_from_store!(report_file_name)
      CSV.read(uploader.path)
    end
  end
    
end
```


## carrierwave uploader not processing in RSpec

processing is turn off for sake of test speed

```ruby
before do
  DocumentUploader.enable_processing = true
end
```

# save original filename size mime type 

https://github.com/carrierwaveuploader/carrierwave/wiki/How-to:-Store-the-uploaded-file-size-and-content-type


```ruby
class Asset < ActiveRecord::Base
  mount_uploader :asset, AssetUploader

  before_save :update_asset_attributes

  private

  def update_asset_attributes
    if asset.present? && asset_changed?
      self.content_type = asset.file.content_type
      self.file_size = asset.file.size
    end
  end
end
```


## testing with RSpec 

in All examples I'll be suspecting that I'm dealing with a model with mounted Uploader

```ruby
# app/models/document.rb
class User < ActiveRecord::Base
  mount_uploader Avatar
    
  # ...
end

```

and in our specs we have included this helpfull macro file

```ruby
# spec/support/upload_file_macros.rb

require 'carrierwave/test/matchers'
module UploadedFileMacros
  def self.included(base)
    base.send :include, CarrierWave::Test::Matchers
  end

  def uploaded_file
    ActionDispatch::Http::UploadedFile.new({
      :filename => 'blank_pdf.pdf',
      :content_type => 'pdf',
      :tempfile => file_for_upload
    })
  end

  # For comparing the upladed file match
  #
  #    document.file.file.file.should be_identical_to file_for_upload
  # 
  # or you can directly set record file:
  # 
  #    document.file = file_for_upload
  #
  def file_for_upload
    File.new("#{Rails.root}/spec/fixtures/uploads/blank_pdf.pdf")
  end
end
```

### Copy file from one resource to other 

check https://github.com/equivalent/copy_carrierwave_file


### Set and compare existance of file with Carrierwave uploader record specs

...or: How to mock/stub file in model that is using  CarrierWave uploader

```ruby
require 'spec_helper'
describe User do
  include UploadedFileMacros
  
  it do
    user = User.new(avatar: file_for_upload)
    user.avatar.file.exists?  #=>true
    user.avatar.file.file.should be_identical_to file_for_upload
  end
end
```


### Seting a record file in factory

Factory:

```ruby
# spec/factories/documents.rb
FactoryGirl.define do

  factory :document, class: Document do
    description "document"
    
    trait :with_file do
      after :create do |d|
        d.file.store!(File.open("#{Rails.root.to_s}/spec/factories/uploads/blank_pdf.pdf"))
      end
    end
    
  end
end
```

in spec file:

```ruby
# spec/models/document_spec.rb
require 'spec_helper'
desc Document do
  include UploadedFileMacros

  let(:document){ create :document, :with_file }
  it 'document should have file' do
    document.file.file.file.should be_identical_to file_for_upload
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


# how to have different storage in test enviroment for carrierwave

using initializer

```ruby
# config/initializers/carrierwave.rb
if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
else
  CarrierWave.configure do |config|
    config.storage = :fog
  end
end
```

or directly in uploader

```ruby
  class MyUploader
    storage(Rails.configuration.carrierwave_storage_type)
  end
```

# factory girl of model using carrierwave

```ruby
FactoryGirl.define do
  factory :archive_file do
    association :archive
    title "MyString"
    description "MyText"

    trait :with_file do
      after(:build) do |af|
        af[:file] = 'dummy.txt'
      end
    end
  end
end

FactoryGirl.build :archive_file, with_file
```

or better 

```ruby
# Read about factories at https://github.com/thoughtbot/factory_girl
include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :photo do
    association :event
    association :entry
    photo { fixture_file_upload(Rails.root.join(*%w[spec fixtures
files example.jpg]), 'image/jpg') }
    description "MyString"
  end
end
```

# wattermarks

Process files as they are uploaded:

```ruby
    process :resize_to_fill => [850, 315]
    process :convert => 'png'
    process :watermark

    def watermark
      manipulate! do |img|
        logo =
Magick::Image.read("#{Rails.root}/app/assets/images/watermark.png").first
        img = img.composite(logo, Magick::NorthWestGravity, 15, 0,
Magick::OverCompositeOp)
      end
    end
```

source: 

* https://gist.github.com/yortz/718055 carrierwave wattermarks and lot of
more options
* https://github.com/rheaton/carrierwave-video

# Issues 

### RMagick complaining about libMagickCore.5.dylib not found in OSX

1/ search for this lib in the system 

    sudo find / -name "libMagickCore.5.dylib" -print

I found mine in `usr/local/Cellar/imagemagick/6.7.7-6/lib/libMagickCore.5.dylib`

2/ link this library to required path 

    ln /usr/local/Cellar/imagemagick/6.7.7-6/lib/libMagickCore.5.dylib /usr/local/lib/libMagickCore.5.dylib
    
http://stackoverflow.com/questions/19040932/rmagick-complaining-about-libmagickcore-5-dylib-not-found-in-osx/19040933#19040933


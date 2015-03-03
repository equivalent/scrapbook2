# Carrierwave uploader not triggering proces in RSpec

processing is turn off for sake of test speed

```ruby
# spec/my_test.spec
before do
  DocumentUploader.enable_processing = true
end
```

It's probably because you have something like

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

I recommend to keep the `enable_processing = false` and just
overide it when needed

 [official guide](https://edgeguides.rubyonrails.org/active_storage_overview.htm) 

Basics

```ruby
class User < ApplicationRecord
 has_one_attached :avatar
 has_many_attached :documents
end
```

## Processing images (variants)


In order to do image processing you need to include
[MiniMagic gem](https://github.com/minimagick/minimagick)

```ruby
# Gemfile
# ...
gem 'mini_magick'
# ...
```

MiniMagic is a Ruby library that delegates commands to C program
[ImageMagic](https://www.imagemagick.org/). So it's
`Rails > ActiveStorage > MiniMagic > ImageMagic`

Therefore you need to have imagemagic installed !


### resize to scale variant

```erb
<%= image_tag user.avatar.variant(resize: "200x150>") %>
```

> Maning if I upload image `1000x500` I want it to be scaled up to  `200x150` maning the end image will be `200x100` px

### resize to fit (crop image to fit) variant


In [Rails official guild](https://edgeguides.rubyonrails.org/active_storage_overview.html#transforming-images) you may find example:

```erb
<%= image_tag user.avatar.variant(resize_to_fit: [200, 150]) %>
```

> Maning if I upload image `1000x500` I want it to be scaled to `333X100` and then croped to fit `200x100` px

This will not work in Rails 5.2 due to reason [described here](https://github.com/janko-m/image_processing/issues/39#issuecomment-387466180)

> Active Storage 5.2 still uses MiniMagick directly, so there are no #resize_* macros available there. The ImageProcessing addition to Active Storage was merged after 5.2 was released, so it's currently available only on GitHub and will be released in Active Storage 6.0. The mogrify command indicates that MiniMagick::Image class is used, as ImageProcessing gem uses convert.


workaround while ActiveStorage 6 is released:

```ruby
head_image.variant(combine_options: {
  auto_orient: true,
  gravity: "center",
  resize: "200x150^",
  crop: "200x150+0+0"})
```

### representation


* https://api.rubyonrails.org/classes/ActiveStorage/Variation.html
* [representation](https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-variant
* https://github.com/rails/rails/blob/b2eb1d1c55a59fee1e6c4cba7030d8ceb524267c/activestorage/app/controllers/active_storage/representations_controller.rb

* https://github.com/rails/rails/issues/35028

```ruby
blob.representation(resize: "100x100").processed.service_url
```

### active storage direct upload to AWS S3


```ruby
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<CORSRule>
    <AllowedOrigin>*</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <MaxAgeSeconds>3000</MaxAgeSeconds>
    <AllowedHeader>Authorization</AllowedHeader>
</CORSRule>
<CORSRule>
    <AllowedOrigin>https://www.sajtka.com</AllowedOrigin>
    <AllowedMethod>PUT</AllowedMethod>
    <MaxAgeSeconds>3000</MaxAgeSeconds>
    <AllowedHeader>*</AllowedHeader>
</CORSRule>
</CORSConfiguration>


```


To allow only certain file types
([source](https://aws.amazon.com/premiumsupport/knowledge-center/s3-allow-certain-file-types/))

```
   <AllowedOrigin>https://app.pobble.com</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>POST</AllowedMethod>
    <AllowedMethod>PUT</AllowedMethod>
    <ExposeHeader>Accept-Ranges</ExposeHeader>
    <ExposeHeader>Content-Range</ExposeHeader>
    <ExposeHeader>Content-Encoding</ExposeHeader>
    <ExposeHeader>Content-Length</ExposeHeader>
    <ExposeHeader>Access-Control-Allow-Origin</ExposeHeader>
    <AllowedHeader>*</AllowedHeader
```

https://github.com/rails/rails/issues/30723

### sources

* <https://edgeguides.rubyonrails.org/active_storage_overview.html>
* <https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html>


* <https://aws.amazon.com/premiumsupport/knowledge-center/s3-allow-certain-file-types/>

* <https://github.com/equivalent/s3_bunny>

Other articles

* <https://mikerogers.io/2018/11/03/configuring-cors-on-s3-for-activestorage.html>


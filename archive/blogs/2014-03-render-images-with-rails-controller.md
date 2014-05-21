# Render image with Rails controller

Let say you want to be able to render dynamic logo on your page. The
logo will be rendered depending on who will be logged in. Of course you
can do: 

```ruby
# app/helpers/application_helper.rb
def logo_image
  if true  # if admin
    'http://www.gravatar.com/avatar/c2713a4959692f16d27d2553fb06cc4b.png?r=x&s=170
  else 
    'some other image'
  end
```

```haml
# app/views/layouts/application_layout.html.haml
= image_tag logo_image
```
 
... but what if you want to hide remote / cloud URLs on your page (S3
Amazon people in da house ?)

So what we are looking for is dynamic render from some kind of  Branding Controller:

```ruby
# config/routes.rb
get 'logo', to: "branding#logo"
```

```haml
-# app/views/layouts/application_layout.html.haml
= image_tag 'logo.png'
```

for **Local stored files**

```ruby
class BrandingController < ApplicationController
  def logo
    send_file 'public/rails.png', type: 'image/png', disposition: 'inline'
  end
end
```
for **Remote stored files**

(according to
http://api.rubyonrails.org/classes/ActionController/DataStreaming.html)

```ruby
class BrandingController < ApplicationController
  def logo
    data = open("http://www.gravatar.com/avatar/c2713a4959692f16d27d2553fb06cc4b.png?r=x&s=170") 
    send_data data, type: image.content_type, disposition: 'inline'
  end
end
```

According to [this](http://stackoverflow.com/a/15028162) StackOverflow
answer, more arguments may be nedded: 

```ruby
send_data data.read, filename: "#{type}.png", type: data.content_type, disposition: 'inline',  stream: 'true', buffer_size: '4096'
```

...but it seems that was ment for older Rails versions because Rails 4 doesn't do
anything with those extra options for streaming
[Rails Data Streaming](https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/metal/data_streaming.rb).

Also  you don't need `filename` option as you are rendering file in browser
(the `disposition: 'inline'` option) not telling browser to download the
file.

If you want do tell browser to download file, syntax should be something
like:

```ruby
send_data generate_tgz('dir'), filename: 'dir.tgz'
```

## CarrierWave gem

One may ask if specifying MimeType is important. Modern browsers will
automatically determine what MimeType they are dealing with from the
first few bytes of file. Well if you you want really easy functionality
for modern Browsers only you may ignore passing of mime type.

What I found out interesting was that when I didn't specify content type
in `send_data` & `send_file` newer browsers were rendering images
correctly. However when I visited controller path, browser was trying to
download the image (you know that pop up thing if you want to save
file). This happened despite the `disposition: 'inline'` option.

It's obvious that Mime Type is important.

If you want to be lazy you can at least pass `type: 'image/png'` for all
send files (I'm not recommending this, in fact it's a terrible idea !!!)

Another way is to determine mime type from file name 

```ruby
MIME::Types.type_for("filename.gif").first.content_type # => "image/gif"
```

But this it's just fetching mime type by extension.

Rather store mime type in your database

Sources:

* http://stackoverflow.com/questions/12277971/using-send-file-to-download-a-file-from-amazon-s3
* http://www.ruby-doc.org/stdlib-1.9.3/libdoc/open-uri/rdoc/OpenURI.html
* http://stackoverflow.com/questions/299999/rendering-file-with-mime-type-in-rails
* http://maxivak.com/rails-link_to-to-download-an-image-immediately-instead-of-opening-it-in-the-browser-send_file-and-remote-files/
* http://api.rubyonrails.org/classes/ActionController/DataStreaming.html
* http://stackoverflow.com/a/15028162 
* https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/metal/data_streaming.rb

Keywords: Rails 4, Ruby 2, Data Streaming, CarrierWave, OpenURI, send
image

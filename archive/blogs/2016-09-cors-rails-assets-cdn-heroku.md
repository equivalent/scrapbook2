# Various CORS issues related (not only to) Ruby on Rails

I'm writing this article after week full of CORS issues that I've
stumbled upon. Truth is that topic of CORS is well documented, it's just
that googling and trying out misleading
detours was too painful.

That's why I'm crating a
collection of issue-solution topics related to CORS along with Ruby on Rails framework.

Hope they will help you (and myself as I'm pretty sure I will have to deal with them in the future).

## Quick explanation what is CORS

I didn't quite understand CORS until I've read this article [Using CORS 
By Monsur Hossain](http://www.html5rocks.com/en/tutorials/cors/)

I will save you from my poor version of explaining it and I will just
say that no mater how experienced in CORS you think you are, read it!

I'll just borrow this explanation from the article:

> Imagine the site alice.com has some data that the site bob.com wants to access. This type of request traditionally wouldn’t be allowed under the browser’s same origin policy. However, by supporting CORS requests, alice.com can add a few special response headers that allows bob.com to access the data.

So here is mine version of the same: If you are on website `bob.com` and website wants some data from
`alice.com`, **your browser** will send request to `alice.com` **including
header** `origin=bob.com`. Website `alice.com` (may or may not) responds with data.
This response includes header `Access-Control-Allow-Origin`. If the
value matches `bob.com` your browser allow to serve that data. If not your **browser**
refuse to serve the data from `alice.com` and your browser console will display error:

Firefox:

```
Cross-Origin Request Blocked: The Same Origin Policy disallows reading the remote resource at [url]. This can be fixed by moving the resource to the same domain or enabling CORS. [url]
```

Chrome:

```
XMLHttpRequest cannot load http://api.alice.com. Origin http://api.bob.com is not allowed by Access-Control-Allow-Origin.
```


## Ruby on Rails asset files under CDN pointing to other assets under CDN

It's super easy to set up CDN in Ruby on Rails ([Official Docs](http://guides.rubyonrails.org/asset_pipeline.html#cdns)). All you have to do:

```ruby
# config/environments/production.rb
Rails.application.configure do
  # ...
  config.action_controller.asset_host = "https://xxxxxxxxxxxxxx.cloudfront.net"
  # ...
end
```

Now your website will point compiled `css`, `js` and images in `app/assets/` folder to CDN.
So instead of `http://mywebsite.com/assets/funny-cat-xxxxxxxx.jpg` you
will have link `https://xxxxxxxxxxxxxx.cloudfront.net/assets/funny-cat-xxxxxxxx.jpg`

> CDN will just pull the original file from `http://mywebsite.com/....`
> and cache it for a while.

The not so fun part starts when your assets behind CDN are pointing to other assets in CDN.
So for example in your `application.css.erb` you are loading something
like:

```erb
# app/assets/application.css.erb
# ...
background-image: '<%= asset_path "funny-cat.jpg" %>';`
# ...
```

Without CDN you would get `background-image: '/assets/funny-cat-xxxxxxxx.jpg'`, therefore
**same origin** content.

With CDN you will get `background-image: 'https://xxxxxxxxxxxxxx.cloudfront.net/assets/funny-cat-xxxxxxxx.jpg'`, therefore cross origin resource.

CDN has also another feature. **It pulls the response headers from asset
server**. Therefore if you want your CDN to respond with proper CORS
header (`Access-Control-Allow-Origin`) you need make sure your server
responds with that header.

> You can test any of the solutions bellow with `curl -X GET  -iH "Origin: test" https://xxxxxxxxxxxxxx.cloudfront.net/assets/funny-cat-xxxxxxxx.jpg` Look for `Access-Control-Allow-Origin` header. If there isn't any, you configured something wrong.

#### Nginx Solution

If you are running server on some VM (like Digital Ocean, EC2 AWS, ...)
and you are using NginX (or Apache) you have not much to worry about.

Official Rails Asset Pipeline pretty much recommends to set custom
headers on Nginx level ([source](http://guides.rubyonrails.org/asset_pipeline.html#far-future-expires-header)).

> Doesn't matter what version of Rails you're using.


```
location /assets {
  # add_header 'Access-Control-Allow-Origin' '*';  # use only for debugging

  add_header 'Access-Control-Allow-Origin' 'https://xxxxxxxxxxxxxx.cloudfront.net';
  add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS';

  # ...
}
```

Here are some other references if you need more complex Nginx examples


* https://gist.github.com/equivalent/1dd25306eb28283fa83a920f3134e53e (mine)
* http://enable-cors.org/server_nginx.html
* https://nisdom.com/blog/2014/09/13/cors-font-issues-with-rails/
* http://blog.bigbinary.com/2015/10/31/rails-5-allows-setting-custom-http-headers-for-assets.html


#### Heroku Solution Rails 5

If you're dealing with Rails 5 application with Heroku server, then great. Set this is your
`production.rb`

```ruby
# config/enviroments/production.rb

  # ...
  config.public_file_server.headers = {
    # 'Access-Control-Allow-Origin' => '*',  # only for debugging
    'Access-Control-Allow-Origin' => 'https://xxxxxxxxxxxxxx.cloudfront.net',
    'Access-Control-Request-Method' => %w{GET OPTIONS}.join(",")
  }
  # ...
```

> I guess `config.public_file_server.enabled` needs to be set to true.

More info: http://blog.bigbinary.com/2015/10/31/rails-5-allows-setting-custom-http-headers-for-assets.html

#### Heroku Solution Rails 4 and lower

If you are dealing with Rails 4 and lower under Heroku you will hate me. I have no
solution that I'm sure will work. Please read article [Rails 5 allows setting custom HTTP Headers for assets](http://blog.bigbinary.com/2015/10/31/rails-5-allows-setting-custom-http-headers-for-assets.html) or [this PR](https://github.com/rails/rails/pull/19135)
and you will understand why.

I'll try to point you out to some solutions, but **none of them really
worked for me**:

##### Rack CORS

* https://github.com/cyu/rack-cors

##### Disable CDN for some assets

Seen this in one StackOverflow answer, if you are too desperate you can
use it as temporary solution, but I'm warning you, you are not caching
those assets via CDN.

```
# config/enviroments/production.rb
Rails.application.configure do
  # ...
  config.action_controller.asset_host = Proc.new { |source|
    if source.match(/.*fontawesome.*/) || source.match(/.*lg\.*/)
      "/"
    else
      "https://d2wplhenup91cg.cloudfront.net"
    end
  }
  # ...
end
```

## Enable Access-Control-Allow-Origin header on S3 bucket / CDN

> This part is written as a result of collaborative work of [Anas Alaoui](https://github.com/nenesitooo) and [Me](http://www.eq8.eu)

Another scenario that happened to me and my college was that one JS lib based on canvas was loading image from Cloudfront CDN by Ajax. CDN was loading and caching images from S3 bucket. Browsers (Firefox, Chrome) were refusing the image due to `Access-Control-Allow-Origin` header not being present in the CDN and S3 response.


> One really important thing to point out is that S3 GET CORS were set to `*` (wildcard, allow any origin). As we've learned (after several hours of research) from [this SO Answer](http://stackoverflow.com/a/35278803/473040) **AWS S3 will not expose header Access-Control-Allow-Origin if it's wildcard** !

Step by step solution:

1. Sign in to the AWS Management Console and open the Amazon S3 console
at https://console.aws.amazon.com/s3/
2. In the Buckets list, open the bucket whose properties you want to
view and click "add CORS configuration"

![s3 cors](http://i.stack.imgur.com/acAvH.png)

3. add CORS:

This will work:

```xml
<CORSConfiguration>
  <CORSRule>
    <AllowedOrigin>http://www.mywebsite.com</AllowedOrigin>
    <AllowedOrigin>https://www.mywebsite.com</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>HEAD</AllowedMethod>
    <AllowedMethod>OPTION</AllowedMethod>
  </CORSRule>
</CORSConfiguration>
```


This won't work: !!!

```xml
<CORSConfiguration>
  <CORSRule>
    <AllowedOrigin>*</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
  </CORSRule>
</CORSConfiguration>
```


To test this:


`curl -X GET  -iH "Origin: http://www.mywebsite.com" https://s3-eu-west-1.amazonaws.com/exxxxxx/....`

`curl -X GET  -iH "Origin: http://www.mywebsite.com" https://xxxxxxxxxxxxx.cloudfront.net/media/files/000/082/788/screen/5d8b8d5f_402a_4c71_891b_xxxxxxxxxxxxxxxxxxxx_8_1fnsfwb.JPG?1471955030> /tmp/a`

> One more thing, Origin header must be present othervise AWS S3 will not
> respond with Access-Control-Allow-Origin

Again **CDN like Cloudfront will just cache whatever header S3 will return
with the assets. So if S3 returns the header, CDN will to (you may need
to wait a bit, or invalidate the cache in CDN to see the result)**

> To invalidate Cloudfront cache, go to `AWS Console Web interface > Cloudfront > pick your CDN > Distribution Settings > Invalidations > Create invalidation`. Then specify what to invalidate in CDN. To invalidate everything just save `*`. To invalidate just a portion of assets `uploads/puctures/*`. Depending how many items are in CDN the invalidation may take several hours/days to apply so make sure you invalidate something for debugging first and then invalidate all to fix everything.

##### Common issues:

* you need to invalidate CDN cache or wait a while (few hours/days) in order to see results as CDN caches images with response headers => you need to reload them
* if in Dragonfly gem  you are getting error "SHA must be present" on CDN side make sure your CDN is forwarding "query strings"

##### Sources

* http://stackoverflow.com/questions/17533888/s3-access-control-allow-origin-header
* http://stackoverflow.com/a/35278803/473040


## CORS on uploaded files via Paperclip gem

First of all if your website is under `https://` make sure your
paperclip CDN configuration points to `https://` version of CDN as well.
If you wont do this some browsers will refuse to serve "Mixed content"
(meaning serving http assets on https web-app)

> the https principle apply to Carriewave and Dragonfly too

Example:

```ruby
  config.paperclip_defaults = {
    :storage => :s3,
    :s3_region => 'eu-west-1',
    :s3_credentials => {
      :bucket => ENV['S3_BUCKET_NAME'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    },
    :s3_protocol => 'https',                                 # <- serve via https not http
    :s3_host_alias => 'xxxxxxxxxxxxxx.cloudfront.net',       # <- your CDN host
    :url => ':s3_alias_url', 
    :path => "media/files/:id_partition/:style/:filename"    # <- set it up as you want
  }
```

so you want your assets point to `https://xxxxxxxxxxxxxx.cloudfront.net/uploads/something.jpg` not `http`

Now that you have https in place you want to be sure you have the CORS
accessible on your S3 bucket (set the CORS as described above in section
`Enable Access-Control-Allow-Origin header on S3 bucket / CDN`)

```
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>http://www.myapp.com</AllowedOrigin>
        <AllowedOrigin>https://www.myapp.com</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>HEAD</AllowedMethod>
    </CORSRule>
</CORSConfiguration>
```

> if you have other options feel free to add them, these are just the
> minimum one you'll need, but be aware not to use the wildcard `*` as described
> in above in this article.


And now invalidate any existing assets in your CDN 

Now it should all work.


## Wildcards

The CORS spec is all-or-nothing. It only supports:

* `*` - from everywhere
* `null` - none
* or the exact match `xxxxxxxxxxxxxx.cloudfront.net`

> note: you cannot do `*.cloudfront.net`

You may feel tempted to leave your setup at `*` (What harm could it do ?)
Well please don't !

Use `*` only for debugging. Once you prove concept, ensure that you set
correct full `subdomain.domain.tld` setup.

To read more why: https://www.viget.com/articles/cors-youre-doing-it-wrong


## Alternative definition of CORS

stolen from  http://stackoverflow.com/a/17570351

> CORS provides a mechanism for servers to tell the browser it is OK for
> requesting domain A to read data coming from domain B. It is done by
> including a new Access-Control-Allow-Origin HTTP header in the response.
> If you remember the error message of the introduction, this is exactly
> what the browser is trying to tell you. When a browser receives a
> response from a Cross-Origin source, it will check for CORS headers. If
> the origin specified in the response header matches the current origin,
> it allows read access to the response. Otherwise, you get the nasty
> error message


## Unsorted resources:

* https://www.w3.org/TR/cors/#access-control-allow-origin-response-header
* http://stackoverflow.com/questions/14003332/access-control-allow-origin-wildcard-subdomains-ports-and-protocols
* https://developer.mozilla.org/en-US/docs/Web/HTML/CORS_enabled_image
* http://blog.bigbinary.com/2015/10/31/rails-5-allows-setting-custom-http-headers-for-assets.html
* https://github.com/rails/rails/pull/19135
* http://stackoverflow.com/questions/25945419/how-do-i-configure-access-control-allow-origin-with-rails-and-nginx
* http://api.rubyonrails.org/classes/ActionView/Helpers/AssetUrlHelper.html
* http://www.html5rocks.com/en/tutorials/cors/
* https://developer.mozilla.org/en-US/docs/Web/HTML/CORS_enabled_image
* http://enable-cors.org/server_nginx.html
* https://www.viget.com/articles/cors-youre-doing-it-wrong
* https://www.w3.org/TR/cors/#access-control-allow-origin-response-header
* https://aws.amazon.com/blogs/aws/amazon-s3-cross-origin-resource-sharing/
* http://stackoverflow.com/questions/20518524/no-access-control-allow-origin-header-is-present-on-the-requested-resource-or#comment30675068_20518524
* http://stackoverflow.com/a/17570351


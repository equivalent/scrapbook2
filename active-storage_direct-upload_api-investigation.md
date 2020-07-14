# ActiveStorage Direct Upload to Azure Blob  - Ruby or Rails JSON API investigation

This document is an investigation  document on how in  [Ruby on Rails](https://rubyonrails.org/) 6.0.3 as a [JSON API](https://guides.rubyonrails.org/api_app.html) do [ActiveStorage](https://edgeguides.rubyonrails.org/active_storage_overview.html) direct upload via
when configured to  [Azure storage (Azure Blob)](https://docs.microsoft.com/en-us/rest/api/storageservices/Put-Blob?redirectedfrom=MSDN)

This is just my personal investigation with helpful notes for my scenario, and not an article with an end
solution. If you find it helpful, great ! I'm happy. If you find an error there is no
comment section so pls PR raise Github issue or email me `equivalent@eq8.eu` or reply to [Reddit post](https://www.reddit.com/r/ruby/comments/hqxsk7/notes_only_activestorage_direct_upload_to_azure/)

By Scenario  is that:

* BE is Ruby on Rails 6.0.3 application that works as JSON API only (`rails new xxx --api`)
* FE is independent React JS app maintained by separte FE team
* BE is uploading files via ActiveStorage to Azure Blobs 
* So far we've been uploading images/files via ActiveStorage via standard
  requests to RoR server and we want to refactor it to Direct cloud Uploads

If this is not your case and you are looking for Active Storage Direct Upload  with native Ruby on Rails forms
this document will not be helpful for you and I recommend you to check
the official [documentation for Active Storage Direct
Uploads](https://edgeguides.rubyonrails.org/active_storage_overview.html#direct-uploads)




## Investigation


### Normal upload

Normaly upload via Active Storage would go like this:

```
FE -> Rails server -> Azure blob
```

* request body is the file
* resp 200

### Direct upload

with direct  upload it is 2 requests

1. request to Rails app to get the presigned url for uploading file
   (plus it will write a record to DB `ActiveStorage::Blob`)
2. PUT request to upload file to the cloud (Azure Blob)

So it can be translated to 

1. `FE -> Rails server (returns presigned url)`
2. `FE -> upload file to presigned url of Azure Blob' (returns empty body)`

#### 1. Request to fetch presigned url

```
post /v3/direct_uploadads
```

> note `/v3/direct_uploads` is custom controller [described bellow](https://github.com/equivalent/scrapbook2/blob/master/active-storage_direct-upload_api-investigation.md#custom-controlloller-for-v3direct_uploads).


* JSON request with params:
  * content type
  * bytesize
  * checknsum
  * filename


example:

```json
{ "blob": { "filename": "jesen.jpg", "byte_size": 618485, "checksum": "UKDEkLYULgzFbaQjXk7M8A==", "content_type": "image/jpg" } }
```

* response is JSON containing  pre-signed URL which then FE can use to
  Direct Upload to cloud (azure storage blob)

example:

```json
{"id":1,"key":"vpti1ws7d7bom8phb8rudtb2ohtv","filename":"test.jpg","content_type":"image/jpg","metadata":{},"byte_size":618485,"checksum":"UKDEkLYULgzFbaQjXk7M8A==","created_at":"2020-07-10T10:25:38.244Z","signed_id":"eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBCZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--10ca83a6ec6ede925d8a6b1829da43d07bcaf071","direct_upload":{"url":"https://tomasapidevelopment.blob.core.windows.net/myproject-api-tomas/vpti1ws7d7bom8phb8rudtb2ohtv?sp=rw\u0026sv=2016-05-31\u0026se=2020-07-10T10%3A30%3A38Z\u0026sr=b\u0026sig=9MoHQZuMl9kLb0s%2BRY64J%2BEIe3GmrjLNhcY6SPakEhE%3D","headers":{"Content-Type":null,"Content-MD5":"UKDEkLYULgzFbaQjXk7M8A==","x-ms-blob-type":"BlockBlob"}}}
```

##### curl example

```
curl -X POST -H "Content-Type: application/json" -d @/tmp/params.json http://localhost:3000/v3/direct_uploads > /tmp/output`
```


`/tmp/params.json` example file:


```json
{ "blob": { "filename": "jesen.jpg", "content_type": "image/jpg", "byte_size": 618485, "checksum": "UKDEkLYULgzFbaQjXk7M8A==" } }
```

> NOTE: Response JSON may contain UTF8 characters like `\u0026sr`. I use `irb` to get the presigned url with: `require 'json'; puts JSON.parse(File.read '/tmp/output')['direct_upload']['url']`


#### 2. upload file to Azure Blob via direct presigned url

* this is html form multipart PUT request
* link has an expiry
* it's a `PUT` not `POST` ([why?](https://blog.eq8.eu/article/put-vs-patch.html))
* for size limit or restrictions RTFM https://docs.microsoft.com/en-us/rest/api/storageservices/Put-Blob?redirectedfrom=MSDN


##### curl example

```
curl -XPUT  --data-binary '@/home/t/git/my-app/my-app-api/tmp/jesen.jpg' -H "x-ms-blob-type: BlockBlob" "https://tomasapidevelopment.blob.core.windows.net/my-app-api-tomas/we3nch48ttnpo8cc66xh775c55wo?sp=rw&sv=2016-05-31&se=2020-07-14T06%3A43%3A22Z&sr=b&sig=gdr66DrU3E%2BhEfE%2BkQ6LLMACt3mcjKd%2FH%2BuT2dYLBgc%3D"
```


Important `curl` Note: 

curl `-F` will **not work**

`curl -XPUT  -F 'data=@/home/t/git/my-app/my-app-api/tmp/jesen.jpg' -H "x-ms-blob-type: BlockBlob" "https://tomasapidevelopment.blob.core.windows.net/my-app-api-tomas/xxxx" # will not work` 


curl `-d` will **not work**

`curl -XPUT -d @/home/t/git/my-app/my-app-api/tmp/jesen.jpg -H "x-ms-blob-type: BlockBlob" "https://tomasapidevelopment.blob.core.windows.net/my-app-api-tomas/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # will not work`


#### step 3 (optional) - test it it works - fetch file

in `rails c`:

```ruby
app.url_for(ActiveStorage::Blob.last)
```

Url of the image processed by Active Storage e.g. :`http://localhost:3000/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBFdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--040a4233cfc8b8698d3224789f48c4997f5879de/jesen.jpg`

### custom controlloller for /v3/direct_uploads

Rails comes with built in endpoint `POST /rails/active_storage/direct_uploads` but I find it that it's better for my scenario to introduce custom controller that inherits from this controller.
Reason is CSRF protection issues and custom auth


```ruby
class V3::DirectUploadsController <  ActiveStorage::DirectUploadsController
  skip_before_action :verify_authenticity_token #  this is for my scenario only,
                                                # do this only if you really undertand CSRF protection
                                                # and when it's ok not to have it

  # Some other solutions on intertet recommend;
  # `before_action :protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }`

  before_action :verify_user

  # controller has only #create action
  def create
    super
  end

  private

  def verify_user
    # .. your code
    # raise 401 or 403 if not authenticated or authorized
  end
end
```

```
#config/routes
Rails.application.routes.draw do
  namespace :v3 do
    # ...
    resource :direct_uploads, only: [:create]
    # ...
  end
end
```


### How checksum is being calculated

Most anoying bit is that in order to get the presigned URL from Rails
you need to send request with checksum (and bytesize, mime type,... but
checksum is most anoying)

In Ruby checksum is calculated like:

```ruby
io = File.open(Rails.root.join('tmp/jesen.jpg'), 'r')

def compute_checksum_in_chunks(io)
  Digest::MD5.new.tap do |checksum|
   while chunk = io.read(5.megabytes)
     checksum << chunk
   end

   io.rewind
  end.base64digest
end

checksum, bytesize =  compute_checksum_in_chunks(io), io.size
```


In JS it

https://github.com/rails/rails/blob/11781d063202b710f8f33f9e823ff22aa2a176ae/activestorage/app/assets/javascripts/activestorage.js#L447

## JS part (e.g. React) 

no notes here. I'm not a SPA  developer. If we discover something usefull I'll update
the docs.

Best I can offer is some JS Articles that may point you in right
direction:


* https://medium.com/@liroy/active-storage-file-upload-behind-the-scenes-59a660c43781

and the native Rails JS files are located in

* https://github.com/rails/rails/blob/11781d063202b710f8f33f9e823ff22aa2a176ae/activestorage/app/assets/javascripts/activestorage.js


I'm pretty sure React / Angular developers can figure out how to do checksum, bytesize and POST
and PUT request.

 Let me just highlight one important thing: when you upload file larger
than certain ammount to Azure Blob you need to split it into chunks and
provide content lenght header.



## other helpfull links



* https://medium.com/@liroy/active-storage-file-upload-behind-the-scenes-59a660c43781
* https://docs.fineuploader.com/branch/master/features/azure.html
* https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
* https://docs.microsoft.com/en-us/rest/api/storageservices/Put-Blob?redirectedfrom=MSDN
* http://www.matrichard.com/post/so-you-want-to-upload-in-azure-storage-from-a-browser-do-you--dont-forget-cors
* https://stackoverflow.com/questions/28894466/how-can-i-set-cors-in-azure-blob-storage-in-portal/41351674#41351674
* https://github.com/rails/rails/blob/badba9d2fa90ae96a5d8428b0a739e18b1581607/activestorage/app/models/active_storage/blob.rb#L117


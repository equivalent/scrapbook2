# ActiveStorage Direct Upload to Azure Blob  - Ruby or Rails JSON API investigation

This document is investigation on how to do direct upload to Ruby on Rails 6 (further referenced as RoR) as JSON API only via
ActiveStorage when configured on Azure Blob

This is just my personal investigation with helpful notes for my scenario, and not an article with an end
solution.

my Scenario  is that:

* BE is Ruby on Rails 6.0.3 application that works as JSON API only
* FE is independent React JS app maintained by separte FE team
* BE is uploading files via ActiveStorage to Azure Blobs 
* Sofar we've been uploading images/files via ActiveStorage via standard
  requests to RoR server and we want to refactor it to Direct cloud Uploads

If this is not your case and you are looking for Active Storage Direct Upload  with native RoR forms
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

### Directu upload

with direct  upload it is 2 requests

```
Post /v3/direct_uploadads 
FE -> Rails server (returns presigned url)
```

> note `/v3/direct_uploadads` is custom controller described bellow

* JSON request with params:
  * content type
  * bytesize
  * checknsum
  * filename


example:

```json
{ "blob": { "filename": "test.jpg", "byte_size": 618485, "checksum": "UKDEkLYULgzFbaQjXk7M8A==", "content_type": "image/jpg" } }
```
 
* response is JSON containing  pre-signed URL which then FE can use to
  Direct Upload to cloud (azure storage blob)

example:

```json
{"id":1,"key":"vpti1ws7d7bom8phb8rudtb2ohtv","filename":"test.jpg","content_type":"image/jpg","metadata":{},"byte_size":618485,"checksum":"UKDEkLYULgzFbaQjXk7M8A==","created_at":"2020-07-10T10:25:38.244Z","signed_id":"eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBCZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--10ca83a6ec6ede925d8a6b1829da43d07bcaf071","direct_upload":{"url":"https://tomasapidevelopment.blob.core.windows.net/myproject-api-tomas/vpti1ws7d7bom8phb8rudtb2ohtv?sp=rw\u0026sv=2016-05-31\u0026se=2020-07-10T10%3A30%3A38Z\u0026sr=b\u0026sig=9MoHQZuMl9kLb0s%2BRY64J%2BEIe3GmrjLNhcY6SPakEhE%3D","headers":{"Content-Type":null,"Content-MD5":"UKDEkLYULgzFbaQjXk7M8A==","x-ms-blob-type":"BlockBlob"}}}
```

2nd  request is invoked on Azure blob

```
FE -> presigned url to Azure blob
```


* html form multipart PUT request

e.g.:

```
curl -XPOST https://tomasapidevelopment.blob.core.windows.net/myproject-api-tomas/xxxxxxx -d @./tmp/jesen.jpg  -H "Content-Type: image/jpg" -H "Content-MD5: UKDEkLYULgzFbaQjXk7M8A==" -H "Content-Length: 618485" -H "x-ms-blob-type: BlockBlob"
```

## custom controlloller

Rails comes with built in endpoint `POST /rails/active_storage/direct_uploads` but I find it that it's better for my scenario to introduce custom controller that inherits from this controller.
Reason is CSRF protection and custom auth


```ruby
class V3::DirectUploadsController <  ActiveStorage::DirectUploadsController
  skip_before_action :verify_authenticity_token #  this is for my scenario only
  # Some other solutions on intertet recommend;
  # `before_action :protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }`

  before_action :verify_user

  # controller has only #create action
  def create
    super
  end

  private

  def verify_user
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

In ruby it's calculated like:

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


###  JS articles

Lot of JS analyses can be find in article 

* https://medium.com/@liroy/active-storage-file-upload-behind-the-scenes-59a660c43781

and the JS files are located in

* https://github.com/rails/rails/blob/11781d063202b710f8f33f9e823ff22aa2a176ae/activestorage/app/assets/javascripts/activestorage.js




========================================

# Notes without any order


curl -X POST -H "Content-Type: application/json" -d @./tmp/params.json http://localhost:3000/v3/direct_uploads

* https://medium.com/@liroy/active-storage-file-upload-behind-the-scenes-59a660c43781
* https://docs.fineuploader.com/branch/master/features/azure.html
* https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
* https://docs.microsoft.com/en-us/rest/api/storageservices/Put-Blob?redirectedfrom=MSDN
* http://www.matrichard.com/post/so-you-want-to-upload-in-azure-storage-from-a-browser-do-you--dont-forget-cors
* https://stackoverflow.com/questions/28894466/how-can-i-set-cors-in-azure-blob-storage-in-portal/41351674#41351674
* https://github.com/rails/rails/blob/badba9d2fa90ae96a5d8428b0a739e18b1581607/activestorage/app/models/active_storage/blob.rb#L117


```json
{"id":1,"key":"vpti1ws7d7bom8phb8rudtb2ohtv","filename":"test.jpg","content_type":null,"metadata":{},"byte_size":618485,"checksum":"UKDEkLYULgzFbaQjXk7M8A==","created_at":"2020-07-10T10:25:38.244Z","signed_id":"eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBCZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--10ca83a6ec6ede925d8a6b1829da43d07bcaf071","direct_upload":{"url":"https://tomasapidevelopment.blob.core.windows.net/myproject-api-tomas/vpti1ws7d7bom8phb8rudtb2ohtv?sp=rw\u0026sv=2016-05-31\u0026se=2020-07-10T10%3A30%3A38Z\u0026sr=b\u0026sig=9MoHQZuMl9kLb0s%2BRY64J%2BEIe3GmrjLNhcY6SPakEhE%3D","headers":{"Content-Type":null,"Content-MD5":"UKDEkLYULgzFbaQjXk7M8A==","x-ms-blob-type":"BlockBlob"}}}
```




```
curl -XPOST https://tomasapidevelopment.blob.core.windows.net/myproject-api-tomas/vpti1ws7d7bom8phb8rudtb2ohtv?sp=rw\u0026sv=2016-05-31\u0026se=2020-07-10T10%3A30%3A38Z\u0026sr=b\u0026sig=9MoHQZuMl9kLb0s%2BRY64J%2BEIe3GmrjLNhcY6SPakEhE%3D -d @./tmp/jesen.jpg  -H "Content-Type: image/jpg" -H "Content-MD5: UKDEkLYULgzFbaQjXk7M8A==" -H "Content-Length: 618485" -H "x-ms-blob-type: BlockBlob"j
```



### ./tmp/params.json example


```json
{ "blob": { "filename": "jesen.jpg", "content_type": "image/jpg", "byte_size": 618485, "checksum": "UKDEkLYULgzFbaQjXk7M8A==", "metadata": {"foo": "bar"} } }
```

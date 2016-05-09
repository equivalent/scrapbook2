# paperclip

## testing upload file

```
 include Rack::Test::Methods

post "/upload/", "attachement" => Rack::Test::UploadedFile.new("path/to/file.ext", "mime/type")
```



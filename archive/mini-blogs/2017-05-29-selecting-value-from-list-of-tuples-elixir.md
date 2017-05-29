# Selecting value from list of tuples Elixir

Elixir

Let say we have Array of tuples (e.g. from AWS
[ex_aws](https://github.com/CargoSense/ex_aws) S3 `head_object`
response):

```elixir
s3_headers = %{headers: [{"x-amz-id-2","yQKurzVIApkxxxxxxxxxxxxxxxxxxxxxxxxxxxxxFBINsPxe+7Vc="},
  {"x-amz-request-id", "82xxxxxxxxx23"},
  {"Date", "Thu, 25 May 2017 22:03:09 GMT"},
  {"Last-Modified", "Thu, 25 May 2017 21:42:28 GMT"},
  {"ETag", "\"6f04733333333333333368997\""},
  {"x-amz-meta-original_name", "Screenshot from 2016-11-27 17-32-03.png"},
  {"Accept-Ranges", "bytes"}, {"Content-Type", ""},
  {"Content-Length", "612391"}, {"Server", "AmazonS3"}], status_code: 200}
```

And we want to exctract  only some to local variables so that we can
store them in DB.


#### Using keyfind

One way to do it is with elixir's `List.keyfind/2`


```elixir
# ...

{"x-amz-meta-original_name", original_name } = s3_headers |> List.keyfind("x-amz-meta-original_name", 0)
{"Content-Length", content_length }          = s3_headers |> List.keyfind("Content-Length", 0)
{"Content-Type", content_length }            = s3_headers |> List.keyfind("Content-Type", 0)

document = %{}Document
|> Document.changeset(%{
	original_name: original_name,
	s3_content_length: s3_content_length,
	s3_content_type: s3_content_type
})
# ...
```

But that does feel kinda repetitive and waste of time as especially if you have long List of tuples.

#### Convert list of touples to map

Another way is to  convert tuple lists with string keys to a Map:

```elixir
headers = Enum.into s3_headers.headers, %{}

document = %{}Document
|> Document.changeset(%{
	original_name: headers["x-amz-meta-original_name"],
	s3_content_length: headers["Content-Length"],
	s3_content_type: headers["Content-Type"]
})
# ...
```

#### Source

* https://stackoverflow.com/questions/44220937/selecting-value-from-list-of-tuples-elixir

Special thank you to S. Pallen 

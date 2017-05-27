# AWS S3 SNS datetime fromat to ecto databse datetime

When you fetch metadata of S3 file with [ExAws](https://github.com/CargoSense/ex_aws)  `ExAws.S3.head_object2`
you will get something like this:

```elixir
3_headers = %{headers: [{"x-amz-id-2","yQKurzVIApkxxxxxxxxxxxxxxxxxxxxxxxxxxxxxFBINsPxe+7Vc="},
  {"x-amz-request-id", "82xxxxxxxxx23"},
  {"Date", "Thu, 25 May 2017 22:03:09 GMT"},
  {"Last-Modified", "Thu, 25 May 2017 21:42:28 GMT"},
  {"ETag", "\"6f04733333333333333368997\""},
  {"x-amz-meta-original_name", "Screenshot from 2016-11-27 17-32-03.png"},
  {"Accept-Ranges", "bytes"}, {"Content-Type", ""},
  {"Content-Length", "612391"}, {"Server", "AmazonS3"}], status_code: 200}
```

Now if you want to save the `Date` string  ("Thu, 25 May 2017 22:03:09 GMT")  to ecto DB you need to
parse the string with [Timex](https://github.com/bitwalker/timex):

```elixir
{"Date", date } = s3_headers |> List.keyfind("Date", 0)
date = Timex.parse!(date, "%a, %d %b %Y %H:%M:%S %Z", :strftime)
```

...now you can save it to DB:

```elixir
document
|> Document.changeset(%{s3_date: date})
|> Repo.update!
```


Now be careful. AWS is specifying zone as GMT while Ecto uses Etc/UTC

https://www.timeanddate.com/time/gmt-utc-time.html

* GMT is a time zone officially used in some European and African countries. The time can be displayed using both the 24-hour format (0 - 24) or the 12-hour format (1 - 12 am/pm).
* UTC is not a time zone, but a time standard that is the basis for civil time and time zones worldwide. This means that no country or territory officially uses UTC as a local time


Bottom point is if you try to match it back with ExUnit backwords

```elixir
# ...

sd = document.s3_date |> Timex.format!("%a, %d %b %Y %H:%M:%S %Z", :strftime)
assert ^sd = "Thu, 25 May 2017 22:03:09 Etc/UTC"

# original   "Thu, 25 May 2017 22:03:09 GMT"
```

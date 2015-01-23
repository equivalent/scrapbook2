best cheat sheet ever http://www.rubyinside.com/nethttp-cheat-sheet-2940.html

# Request with headers

```ruby
require "net/http"
require "uri"

url = URI.parse("http://www.whatismyip.com/automation/n09230945.asp")

req = Net::HTTP::Get.new(url.path)
req.add_field("X-Forwarded-For", "0.0.0.0")
*emphasized text*
res = Net::HTTP.new(url.host, url.port).start do |http|
  http.request(req)
end

puts res.body
```

vicously stolen from http://www.dzone.com/snippets/send-custom-headers-ruby

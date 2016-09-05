best cheat sheet ever http://www.rubyinside.com/nethttp-cheat-sheet-2940.html

# Net https POST

http://stackoverflow.com/a/39328503/473040

```
require 'uri'
require 'net/https'
require 'json'

class MakeHttpsRequest
  def call(url, hash_json)
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri.to_s)
    req.body = hash_json.to_json
    req['Content-Type'] = 'application/json'
    # ... set more request headers 

    response = https(uri).request(req)

    response.body
  end

  private

  def https(uri)
    Net::HTTP.new(uri.host, uri.port).tap do |http|
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end
end

project_id = 'yyyyyy'
project_key = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
url =
"https://airbrake.io/api/v4/projects/#{project_id}/deploys?key=#{project_key}"
body_hash = {
  "environment":"production",
  "username":"tomas",
  "repository":"https://github.com/equivalent/scrapbook2",
  "revision":"live-20160905_0001",
  "version":"v2.0"
}

puts MakeHttpsRequest.new.call(url, body_hash)

```

# net http timeout

```ruby
    begin
      uri = URI.parse('http://oldwebsite.it')
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 2
      http.open_timeout = 2

      http.get(uri.request_uri)
    rescue Net::OpenTimeout
      # do stuff
    end
```


# https request

My example 

```ruby
class MakeHttpsRequest
  attr_reader :token

  def initialize(token)
    @token = token
  end

  def call(url)
    response(url)
  end

  private
    def response(url)
      uri = URI.parse(url)
      req = Net::HTTP::Get.new(uri.to_s)
      req['Authorization'] = "Token #{token}"

      response = https(uri).request(req)

      response.body
    end

    def https(uri)
      Net::HTTP.new(uri.host, uri.port).tap do |http|
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
end

MakeHttpsRequest.new('secretauthtoken').call('https://blabla.com/api/v1/events')
```


Soultion from http://www.rubyinside.com/nethttp-cheat-sheet-2940.html :

```ruby
require "net/https"
require "uri"

uri = URI.parse("https://secure.com/")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(uri.request_uri)

response = http.request(request)
response.body
response.status
response["header-here"] # All headers are lowercase
```


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
HOWEVER !!

if you want to send 'Accept' header (Accept: application/json) to Rails application, you cannot do:

`req.add_field("Accept", "application/json")`

but do:

`req['Accept'], 'application/json'`

The reason for this is that `add_field` will just append "application/json" to `["*/*"]` (accept any). `'Accept'=>['*/*', 'application/json']` 

Another reason aparantly in sthat Rails ignores the Accept header when it contains “,/” or “/,” and returns HTML
This is by design to always return HTML when being accessed from a browser.
This doesn’t follow the mime type negotiation specification but it was the only way to circumvent old browsers with bugged accept header. They had he accept header with the first mime type as image/png or text/xm

source: 

* http://www.dzone.com/snippets/send-custom-headers-ruby
* http://apidock.com/rails/ActionController/MimeResponds/respond_to#1436-Accept-header-ignored

# post / put json

```ruby
    uri = URI.parse 'https://abcd.efg:3456'
    uri.path = "/virus_scans/#{scan_id}"

    scan_push_req = Net::HTTP::Put.new(uri.to_s)
    scan_push_req.add_field("Authorization", "Token #{token}")
    scan_push_req['Accept'] = 'application/json'
    scan_push_req.add_field('Content-Type', 'application/json')
    scan_push_req
      .body = {"virus_scan" => {'scan_result' => result}}
      .to_json

    response = Net::HTTP.start(uri.host, uri.port) { |http|
      http.request(scan_push_req)
    }
    response.body
```

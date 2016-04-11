# download file with HTTPparty

```
require 'httparty'
module Helper
  def pull_asset(url:, destination:)
    File.open(destination, "wb") do |f|
      f.binmode
      f.write HTTParty.get(url).parsed_response
      f.close
    end
  end
end

Helper.pull_asset(url: 'https://s3.aws....../my-file.jpg', destination: 'tmp')
```

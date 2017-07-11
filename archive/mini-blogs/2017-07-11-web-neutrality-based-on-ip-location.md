# Web neutrality modal displayable only to USA IP addresses

As you all may have heard USA ISP giants Comcast & Verizon want to end
net neutrality and gain full control. This may end up in future that any websites will
not be viewable for their customers unless website/web-app pays them.

Lot of companies decide to protest on 12th of July 2017 and put "call to
action" modal on their websites.

* https://www.battleforthenet.com/#bftn-action-form
* http://www.engine.is/startups-for-net-neutrality

The easiest way to join the protest is put this widget to our website:

https://github.com/fightforthefuture/battleforthenet-widget

The thing is it's really hard to presveide your boss that even though
his is happening in USA every company should join the protest. 

It may be worth stroke a deal with your boss to display this "call to action" modal
only to USA IP addresses.

I will quickly show you 2 solutions that you may implement on your Ruby
on Rails application:


## Pull geo IP locations

If you are able to pull [GeoIP database](http://dev.maxmind.com/geoip/) (e.g. you run your own VM)


```bash
# put this you your deployment script / Dockerfile 
cd ./tmp/
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
gunzip GeoLiteCity.dat.gz
```


Then add gem https://github.com/cjheath/geoip

```ruby
# Gemfile
# ...
gem 'geoip'

```

```ruby
# app/helpers/application.rb
module ApplicationHelper

  # ...

  def net_neutrality
     country_code = GeoIP.new(Rails.root.join('tmp','GeoLiteCity.dat').to_s)
       .city(request.remote_ip)
       .try(:country_code2)

    if country_code == "US"
      javascript_include_tag('https://widget.battleforthenet.com/widget.js', async: "async")
    end
  end
end
```

```erb
# app/views/layouts/application.erb
<html>
  # ...
  <body>
    <%= yield %>
    <%= net_neutrality %>
  </body>
</html>
```

If you are under Heroku or you are not able to pull the GeoIP location
please check next section:

## Use CloudFlare GeoIP feature

If your website is under [Cloudflare](https://www.cloudflare.com/) CDN
you are able to access location of current visitor location thanks to
[Cloudflare Geo IP](https://support.cloudflare.com/hc/en-us/articles/200168236-What-does-Cloudflare-IP-Geolocation-do-)

So your domain under Cloudflare DNS will pass header `HTTP_CF_IPCOUNTRY`
to your Rails app


```ruby
module ApplicationHelper
  def net_neutrality
    cc = request.headers['HTTP_CF_IPCOUNTRY']
    Rails.logger.info("country code is: #{cc} #{request.remote_ip}")

    if cc == "US"
      javascript_include_tag 'https://widget.battleforthenet.com/widget.js', async: "async"
    end
  end
end
```

```erb
# app/views/layouts/application.erb
<html>
  # ...
  <body>
    <%= yield %>
    <%= net_neutrality %>
  </body>
</html>
```


* https://gist.github.com/mahemoff/8ec27ebfe22b89c8669a

## Query 3rd party IP location service


you can call some 3rd party API with IP and it will return you location.

e.g.: 

* http://www.rubygeocoder.com/

Just be careful so that you will not run out of "free credits" to query
or that you will not slow down render of your website while you are
waiting for the response.


## Conclusion

Web neutrality affects us all. If your boss tells you "it's not our
problem" tell him that it will be in year or two. If your boss tells you
"that is just in USA" tell him that other country ISP giants will
definitely push for that trend as ISPs will get super rich from this
act.

If a startup will get push to pay ISP just to appear on ISP's whitelist
then it's the end of the internet as we know it.

I know that displaying this only for USA IPs is not enough, but it's
better then don't display nothing  at all.

# Rails Asset Pipeline compilation and Docker

As you may now [Rails asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html) (a.k.a. Sprockets)
compress your assets (JS, CSS, ...) and inserts hash into file name so
that CDN can pick up the change:

So if you had `app.js` you will have `app-908e25f4bf641868d8683022a5b62f54.js` this way your app will interpret:

```
<html>
  <head>
   <%= javascript_include_tag 'app' %>
  <head>
```

To

```
<html>
  <head>
     <script src="https://dxxxxxxxxx6lt.cloudfront.net/assets/app-908e25f4bf641868d8683022a5b62f54.js">
  <head>
```

Now if we try to dockerize our Rails and assets we will stumble upon
problem.


Idea of Docker is immutability of images and that Docker image for your
Rails app should contain everything it needs. That means that ideally
you would compile assets to your docker image like this:

```bash
# Dockerfile
FROM ruby:2.4.1

# ....

RUN bundle exec rake assets:precompile

# ....

CMD bundle exec puma -C config/puma.rb
```

Now here's the thing. If you have multiple environments (staging, QA,
production) then you will have a problem as for every environment Asset
Pipeline is generating different hash


```markdown
Develop
   app.js     ->         app.js

   No CDN assets are served localhost/app.js

Production
   app.js     ->         app-1212221.js

   CDN                                            ->  Webserver
   myapp-prod.cloudfront.com/app-1212221.js          /app-1212221.js


Staging
   app.js     ->         app-898219.js

   CDN                                            -> Webserver
   myapp-staging.cloudfront.com/app-898219.js        /app-898219.js

```

> Note if you want to read more [here is a GH issue discussion](https://github.com/rails/rails/issues/2569#issuecomment-1857066)


### Different Dockerfile per environment solution

So that means that if you build your Docker image as shown above it will
only work for one environment. That means you will have to build
different docker images for other environments:


```bash
# Dockerfile-prod
# ....
RUN RAILS_ENV=production bundle exec rake assets:precompile
# ....
CMD bundle exec puma -C config/puma.rb
```


```bash
# Dockerfile-staging
# ....
RUN RAILS_ENV=staging bundle exec rake assets:precompile
# ....
CMD bundle exec puma -C config/puma.rb
```

Now that defeats the purpouse of whole "one Docker image for every
environment". 

That means this solution is Not good

### Compile assets at runtime solution

Lot of companies are actually building their docker image without
running `rake assets:precompile` during Docker image build and they
rather run the task at run time:


```bash
# Dockerfile
# ....
CMD run.sh
```

```bash
# run.sh

bundle exec rake assets:precompile && bundle exec puma -C config/puma.rb
```

```bash
$ docker run -d my_rails_app_docker_image -e RAILS_ENV=staging rails s
```

Now this will work but it's a terrible idea. Not only your Docker image
is "incomplete" (assets are valuable part of your web-application =>
needs to be part of your Docker image) but your deployment will take
several minutes to start server as the asset compilation needs to finish
first.


That means this solution is Not good

### One image per multiple environments solution

So only solution is to compile several environments of assets in the
same docker image:


```bash
# Dockerfile
FROM ruby:2.4.1

# ....

RUN RAILS_ENV=staging bundle exec rake assets:precompile
RUN RAILS_ENV=production bundle exec rake assets:precompile
RUN RAILS_ENV=qa bundle exec rake assets:precompile

# ....

CMD bundle exec puma -C config/puma.rb
```

Now this is still not ideal (especially if you want to lunch several
"custom" environments) but it's pretty much only way how you can achive
this with Assets Pipeline.


> Any better solution suggestions are welcome. Write a comment or PR
> this blog article I make sure to include it if it's reasonable
> solution ;)

That means this solution is good but may not be good enough for some
cases

### Theoretical solution to multiple custom environments

If you really need multiple custom environments then only way I can come up with "custom environments" compilation is to build
docker image via some string interpolation template:


```erb
# templates/Dockerfile.erb
FROM ruby:2.4.1

# ....
<% @environments.each do |env| %>
  <%= "RUN RAILS_ENV=#{env} bundle exec rake assets:precompile" %>
<% end %>
# ....

CMD bundle exec puma -C config/puma.rb
```

```ruby
# my_build_script.rb

@environments = ['qa', 'staging', 'production', 'custom-1', 'custom-2'] # you can pass arguments from command line by ARGV

template = File.read('templates/Dockerrun.erb')
evaluated_file = ERB.new(template).result(binding)
File.open('Dockerfile', 'w+') do |f|
  f.write evaluated_file
  f.close
end
```

> I'm writing this template code from top of my head, it may not work

```
ruby my_build_script.rb
```

* https://www.codecademy.com/articles/ruby-command-line-argv


That means this solution is good enough but not as simple as it should
be

### Conclusion

I'm not sure how JavaScript world is tackling this problem. Maybe if the Rails
app was just JSON API and frontend was pure single page JS app
communicating with this API and  where the frontend
assets would be served via a Webpack or some other asset compiling solution that is not 
having similar issue then this may work much simpler.

I don't have experience with it yet (I'm building dummy project in my
free time but I'm not there yet so I don't know yet, maybe in few months
I'll update this article with solution) But it would be great if someone
gives some feedback on this from their personal experience.

One thing is for sure Asset Pipeline may be bit tricky for you if you
want ideal Docker environment.

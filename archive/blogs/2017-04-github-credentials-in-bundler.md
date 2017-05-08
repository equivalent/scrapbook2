# Github credentials in bundler

Recently I've introduced private Github repo the project's `Gemfile`.

```ruby
# Gemfile

# ...
gem 'myprivategem', git: 'git@github.com:myorg/myprivategem.git'
# ...
```

We are using Docker to build our Ruby on Rails application so no
surprise that we got "no permission to repository" from bundler when building our Docker image.

### solution 1 - (BAD) ssh key to Docker image

One way how this would be possible to fix  is to copy ssh keys to Docker container. But this is a big security no-no as anyone who will get
a hand on that docker image can retrieve the ssh private key. This even apply if you delete the key in next line, as Docker image layers
consist of root-file system changes => the key will still be retrievable from previous layer of the docker image.

So do yourself a favor and don't do this !

### solution 2 - https credentials

Another way is to use `https://github.com/...` format instead of `git@github.com:...` format and pass the credentials. In order to do this first you need to
generate [personal Github access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)

Then you need to  pass the credentials to Gemfile similar way like this:

```ruby
# Gemfile

# ...
gem 'myprivategem', git: 'https://myuser:mysecrettoken@github.com/myorg/myprivategem.git'
# ...
```

Now this is not necessary bad approach as long as you **don't commit your Gemfile like this** to source control (git).

You can pass build argument to docker build In Dockerfile, then  you can pass env variable to Gemfile when you run `bundle install`.


```bash
# build script on the build box
docker build -t=live-20170502 --build-arg github_token=xxxxxxxgeneratedxxxxxtokenxxxxxxxxx .
```

```Dockerfile
# Dockerfile

# ...
ARG github_token
RUN GITHUB_TOKEN=$gitub_token bundle install
# ...
```

```ruby
# Gemfile

# ...
gem 'myprivategem', git: 'https://#{ENV['GITHUB_TOKEN']}:x-oauth-basic@github.com/myorg/myprivategem.git'
# ...
```

### solution 3 - Bundler provider credentials


Now the prev. approach is repetitive and messy for development environment. That's why you can set your "provider" credentials via `bundle config`

* http://bundler.io/man/gemfile.5.html#CREDENTIALS-credentials-


**development machine:**

Therefore all that developers in their development machines need to do is:

1. create [personal Github access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) and set [permissions to read repo](https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/generating-personal-key-github.png)

2. run this:

```bash
bundle config  github.com myuser:xxxxxxxgeneratedxxxxxtokenxxxxxxxxx
```

**build machine:**

As for the production docker build would look like this:

```bash
# build script on the build box
docker build -t=live-20170502 --build-arg github_token=xxxxxxxgeneratedxxxxxtokenxxxxxxxxx .
```

```Dockerfile
#Dockerfile

# ...
ARG github_token
RUN bundle config github.com mydeploymentuser:$github_token && (bundle install --without test development) && bundle config --delete github.com
# ...
```

```ruby
# Gemfile

# ...
gem 'myprivategem', git: 'https://github.com/myorg/myprivategem.git'
# ...
```

In this case we are setting the credentials, running the bundle install and removing the credentials is same layer. Therefore credentials will not be committed to the Docker layer.
It's similar to `RUN apt-get update && apt-get install -y imagemagick  && rm -rf /var/lib/apt/lists/*`

## resources


* http://bundler.io/man/bundle-config.1.html#CONFIGURATION-KEYS
* create [personal Github access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)
* http://bundler.io/man/gemfile.5.html#CREDENTIALS-credentials-
* https://gist.github.com/masonforest/4048732
* https://gist.github.com/hone/b0c0093374097313ab7f
* https://raw.githubusercontent.com/equivalent/scrapbook2/master/assets/images/2016/generating-personal-key-github.png

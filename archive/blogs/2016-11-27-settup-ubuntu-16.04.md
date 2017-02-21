# Setting up Ubuntu 16.04 for Ruby on Rails app (Cheatsheet)

Let say you want to quickly set up fresh install **Ubuntu 16.04** for [Ruby on Rails](http://rubyonrails.org/)
application that uses Redis, Elasticache and Postgres.

## Generate ssh key

```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

* https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

## Install RVM + Ruby

https://rvm.io/rvm/install

```sh
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash
source ~/.bash_profile

rvm install 2.3.3

gem install bundler rake
```

## Install PostgreSQL

https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-16-04

```sh
sudo apt-get update
sudo apt-get install postgresql-contrib postgresql-9.5 libpq-dev
```

2016-11-27 you should end up with `postgres` version `9.5`
installed

```sh
psql --version
# psql (PostgreSQL) 9.5.5
```

### setup Postgres user

https://github.com/equivalent/scrapbook2/blob/master/postgresql.md

```sh
# bash
sudo -u postgres psql 
```

```sql
# inside psql

CREATE USER myuser WITH PASSWORD 'myPassword';

# if you want him to be superuser
ALTER USER myuser WITH SUPERUSER;

# if you just want him to be able to create DB
ALTER USER myuser WITH CREATEDB;
```


be sure to set credentials in `config/database.yml` inside your Rails
project and now you can run `rake db:create` or `rake db:migrate`



## Install Redis

> e.g.: if you need [Redis](https://redis.io/) for [Sidekiq](http://rubyonrails.org/) or
> [Resque](https://github.com/resque/resque) or just for [Rails caching server](https://github.com/redis-store/redis-rails))


https://www.digitalocean.com/community/tutorials/how-to-configure-a-redis-cluster-on-ubuntu-14-04

```sh
sudo add-apt-repository ppa:chris-lea/redis-server
sudo apt-get update
sudo apt-get install redis-server
```


2016-11-27 you should end up vith Redis server version 3.0.7

```sh
redis-server --version
# Redis server v=3.0.7 sha=00000000:0 malloc=jemalloc-3.6.0 bits=64 build=6a943c0b5bf37fa1
```

connection should be accepted at `127.0.0.1:6379` (localhost + default
Redis port)

## Install Elasticache

> e.g.: if you need [Elasticsearch](https://www.elastic.co/) for search
> indexation [Elasticsearch Rails](https://github.com/elastic/elasticsearch-rails)

https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-16-04
https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-get-on-ubuntu-16-04

```
sudo apt-get update

# install java
sudo apt-get install default-jre
sudo apt-get install default-jdk

# install elasticache
cd /tmp
wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.3.1/elasticsearch-2.3.1.deb
sudo dpkg -i elasticsearch-2.3.1.deb
sudo systemctl enable elasticsearch.service
```

connection should be accepted at `127.0.0.1:9200` (localhost + default elasticache port)

```
curl 127.0.0.1:9200
```

```bash
sudo systemctl status elasticsearch.service  # status
sudo systemctl start elasticsearch.service   # start server
sudo systemctl stop elasticsearch.service    # stop server
```

## Imagemagic

> if you need image processing inside your Rails app with gems like
> [Carrierwave](https://github.com/carrierwaveuploader/carrierwave),
> [Paperclip](https://github.com/thoughtbot/paperclip) or
> [Dragonfly](https://github.com/markevans/dragonfly)


```
sudo apt-get install  imagemagick libmagickcore-dev libxslt-dev libmagickwand-dev
```

## Docker

https://docs.docker.com/engine/installation/linux/ubuntulinux/

**note:** this is for ubuntu 16.04, for different version you will need diferent Docker source

```bash
# preparation
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y linux-image-extra-$(uname -r) jblinux-image-extra-virtual

# docker install
sudo apt-get update
sudo apt-get install docker-engine
sudo service docker start

# add your user to docker user group (so you don't have to sudo all the time)
sudo groupadd docker
sudo usermod -aG docker $USER
# ...now log out and log back in
```

#### common error 1 - first time docker engine not starting

```
Setting up docker-engine (1.12.5-0~ubuntu-xenial) ...
Job for docker.service failed because the control process exited with
error code. See "systemctl status docker.service" and "journalctl -xe"
for details.
invoke-rc.d: initscript docker, action "start" failed.
dpkg: error processing package docker-engine (--configure):
 subprocess installed post-installation script returned error exit
status 1
Errors were encountered while processing:
 docker-engine
E: Sub-process /usr/bin/dpkg returned an error code (1)
```

**solution**: this is due to docker not able to modify your networking
setup in host (your laptop). To me this was  happening due to fact that
I was connected to VPN and OpenVPN refused to terminate (as
docker-engine was trying to modify network setup). Solution for me was
just to kill OpenVPN for this one ocassion.

But some people reported this bug when they have some custom IPv6 setup, some when Firewal is to
strict...

#### common error 2 - docker daemon not running

when you lunch docker command like `docker ps` you may get:

```
Cannot connect to the Docker daemon. Is the docker daemon running on
this host?
```

try `sudo docker ps`

If it worked, you've just ignored the instruction "log out and log back in". Do it and you should be fine

## Docker Compose (docker-compose)

https://docs.docker.com/compose/install/

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo  chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

## Some common dependancy issues:

#### Qmake

if you get:

```sh
qmake: could not exec '/usr/lib/x86_64-linux-gnu/qt4/bin/qmake': No such
file or directory
*** extconf.rb failed ***
```

do:

```sh
sudo apt-get install qt4-qmake libqt4-dev
```

[source](http://stackoverflow.com/questions/23703864/cmake-not-working-could-not-exec-qmake)

#### capybara webkit

if you get:

```sh
cd src/ && make -f Makefile.webkit_server 
# ...
An error occurred while installing capybara-webkit (1.7.1), and Bundler
cannot continue.
Make sure that `gem install capybara-webkit -v '1.7.1'` succeeds before
bundling.
```

do:

```sh
sudo apt-get install libqtwebkit-dev 
```


## Note

Something missing? Create a Pull Request for this article.

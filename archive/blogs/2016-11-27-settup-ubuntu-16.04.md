# Setting up Ubuntu 16.04 for Ruby on Rails app

Let say you want to quickly set up fresh install **Ubuntu 16.04** for [Ruby on Rails](http://rubyonrails.org/)
application that uses Redis, Elasticache and Postgres.

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
sudo apt-get install postgresql postgresql-contrib
```

2016-11-27 you should end up with `postgres` and `postgresql-client` version `9.5`
installed

```sh
psql --version
# psql (PostgreSQL) 9.5.5
```


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

## Install Elasticache

> e.g.: if you need [Elasticsearch](https://www.elastic.co/) for search
> indexation [Elasticsearch Rails](https://github.com/elastic/elasticsearch-rails)

https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-16-04

```
sudo apt-get update
cd /tmp
wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.3.1/elasticsearch-2.3.1.deb
sudo dpkg -i elasticsearch-2.3.1.deb
sudo systemctl enable elasticsearch.service
```

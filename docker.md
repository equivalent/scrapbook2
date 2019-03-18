# examples

```
docker build -t=static-html-nginx .
docker run --name mytest -d -p 8080:80 static-html-nginx
curl localhost:8080
docker stop mytest

# use local folder content
sudo docker run -it -p 8080:80  -v
/home/local-machine-user/projoct-root/html-content/:/usr/share/nginx/html:ro
stac-html-nginx # or use nginx image directly
```

https://hub.docker.com/_/nginx/


# docker refusing pus after hiting ctrl-c in middle of docker push

scenario

```
sudo docker push quay.io/equivalent/foobar:qa-3
FATA[0000] Error response from daemon: push quay.io/equivalent/foobar is
already in progress 
```

solution

```
$ sudo service docker restart   # on the machine frm which you pushing
```


# quai.io


```
docker run busybox echo "fun" > newfile
deckor ps -l
#  my image is id dbe072c4c613
docker commit dbe072c4c613 quay.io/equivalent/test-docker


```


# docker


* https://github.com/neckhair/rails-on-docker/blob/master/docker-compose.yml
* 


coreos, mesos -linux distros  OS where multiple computers acts as one
computer and they share resources as one comupter. When you run ouf of
resources you can add more machines to cluster => will increase cluster
memory / processor power. This is ideal for docker as it's container is
using only required amounts of memory /processor power.

- docker client (user interface)
- docker daemon (sits on the server )
- docker index == docker repository of docker images (docker hub)
- docker container = actual container running the application includes
  filesystem, ports, processes space isolated from  host
- docker image == equivalent of VM , snapshot of running container, can
  be version controled => `docker diff` => you can check changes and
then push to dockerhub
- docker file =  similar to cheff file, holds instructions how to build
  container
- docker layer = is stacked each time docker mounts root fs



in theory a single docker container should run only one process (ruby
container, postgres container) . When this main process dies docker
container will go down (equivalent of `docker kill`)  (ref: [27:00][1])
... sometimes you want to run multiple processes in onne container
(early development) check supervisor


docker commands 

-  docker run <image>   # creates and run a docker container
- docker pull <image> # pull prebuild image from repo (dockerhub)
- docker commit  # save container state as image (equivalent to a layer)
- docker images # list availible images
- docker diff  # list changes in filesystem
- docker build # build container from a Dockerfile
- docker inspect # low level  docker info on container
- docker logs #  STDOUT of main process
- docker attach #  interact with running container => basivcally run a
  buash on a running container and interact with it like with vm
- docker kill # kill main process of container
- docker start  <name| id> # starts existing docker container
- docker stop  <name| id> 
- docker ps  # list of running containers
- docker ps -a  # list of all containers including those that are not
  running
- docker login  # will login to docker-hub ...or other docker repo
  depending on settings default is docker hub
- docker rm a2cc01627771    # remove image


```
sudo docker build -t qa  .
sudo docker build -t=quay.io/equivalent/foobar:latestbla .
sudo docker exec xyzfabcd ls
sudo docker push quay.io/equivalent/foobar:latestbla
sudo docker run -i -w='/app'  e56b3471f8d6  ruby ./build/getLatestFromOldSite.rb

# execute on running container
sudo docker exec -it 16997394032d bash   # not recommended for long task

docker commit CONTAINER_ID [image_name]  # recommended, commit image state
docker run -it [image_name] /bin/bash    # and run the command on
                                         # commited state

# if you need to link some other docker
sudo docker ps #get the log ID 
sudo docker run -it --link
ecs-awseb-qa-3Pobblecom-env-f7yq6jhmpm-17-elasticsearch-cec6b5bd9bfed4e42b00:elasticsearch
999dockerimage999 bash


# mounting volume
sudo docker run -it -v ~/shared/logs/:/shared/logs 999dockerimage999 bash
```


Dockerfile
- you can replace it with ansible, cheff,... as it is just simple bash
- each command executed creates a layer - if you done mistake on last
  cmd, you wont have to rebuild prev layers

- RUN # exec cmd in a shell
- VOLUME ['/data'] # enable access to host from working container , e.g.
  adding database.yml
- WORKDIR /path/to/workdir  #  set workdir in container
- ADD <src> <destination>  # copy files from one location to other
- CMD ['exec', 'stuff']  # default container execution (like rails
  server)
- ENV <key> <value>  # set env variables
- USER <uid>   # sets user that container is running as
* EXPOSE 123  #port container listen to
 

image is exposing a port to docker-daemon but in order to really access
it you need to map ports to webserver 

- docker run -p 8080:80  tutum/hello-world  # create and run docker
  container + map web-server port 8080 to docker container port 80 

docker run -d --name web1 -p 8081:80 tutum/hello-world  # -d run as
daemon
                                                                                                              #
name it as web1
                                                                                                              #
map port web-server 8081 to port 80 of docker

docker run -d --name web2 -p 8082:80 tutum/hello-world 
docker run -d --name web3 -p 8083:80 tutum/hello-world 

docker ps  # will give you 3 images running
docker stop web2  
docker ps  # will give you 2 images running
docker start web2   

1:14:49


```
docker run -i containername bash        # run bash on container
docker run -d containername sleep 10    # run sleep 10 on container as daemon. after 10s container dies
docker run containername sleep 10      # run sleep 10 on container normal mode => you will wait 10s after which container dies


docker run -i -v /home/ubuntu/mnt containername bash # mount folder and run bash in interactive mode

```



# docker-composer

form [3][docker composer rails]

```
# docker-compose.yml
db:
  image: postgres:9.4.1
web:
  build: .
  command: bundle exec rails s -p 3000 -b '0.0.0.0'
  volumes:
    - .:/myapp
  ports:
    - "3001:3000"
  links:
    - db
```

```
# Dockerfile
FROM ruby:2.2.2
RUN apt-get update -qq && apt-get install -y build-essential

# for json gem
RUN apt-get install -y libc6-dev

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
# RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# for a JS runtime
RUN apt-get install -y nodejs

ENV APP_HOME /myapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME
```

```
# Gemfile
source 'https://rubygems.org'
gem 'rails', '4.2.0'
```

```bash
docker-compose run web rails new . --force --database=postgresql --skip-bundle  # bulid docker + create rails app

# ...or just:
docker-compose run      #build the docker
```

```
# database.yml
development: &default
  adapter: postgresql
  encoding: unicode
  database: postgres
  pool: 5
  username: postgres
  password:
  host: db

test:
  <<: *default
  database: myapp_test
```

```
docker-compose up   # boot the application
cd ~/my-app-with-docker-files
docker-compose run web rake db:create
docker-compose run web rails c
```








## sources and references:

[1]: https://www.youtube.com/watch?v=ddhU3NMrhX4 "3 hours to docker fundaments"
[2]: https://www.youtube.com/watch?v=JBtWxj9l7zM  "Docker Tutorial - Docker Container Tutorial for Beginners"
[3]: https://docs.docker.com/compose/rails/  "docker composer rails"



# install older docker version 

How to Install Docker Engine 1.6.2

    Download the repository key with:

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9

    Then setup the repository:

    $ sudo sh -c "echo deb https://get.docker.io/ubuntu docker main >
/etc/apt/sources.list.d/docker.list"
    $ sudo apt-get update
    $ sudo apt-get install lxc-docker-1.6.2

    Run docker as non-sudo:

    $ sudo usermod -a -G docker $USER
    $ exit

Reference:
http://www.ubuntuupdates.org/ppa/docker?dist=docker55
https://forums.docker.com/t/how-can-i-install-a-specific-version-of-the-docker-engine/1993/6


## Docker compose trash

some examples of what docker compose may do

```
# docker-compose.yml
---
version: '2'
services:
  db:
    image: postgres:9.4.5
    environment:
      POSTGRES_PASSWORD: candy
      POSTGRES_USER: candy
      POSTGRES_DB: development_candy
    volumes:
      - ./tmp/postgres/:/tmp/
      - ./docker/postgres/drop_db_and_restor_dump.sh:/tmp/drop_db_and_restor_dump.sh
  redis:
    image: redis:2.8
  box:
    image: busybox
    volumes:
      - /shared/logs
      - /shared/sockets
      - /shared/pids
      - /shared/certs
      - ./log/:/shared/logs/
      - ./db/development_certs/:/shared/certs/
  nginx:
    image: quay.io/candy/nginx.candy.com:live-20161122
    depends_on:
      - box
    volumes_from:
      - box
    ports:
      - "80:80"
      - "443:443"
  elasticsearch:
    image: elasticsearch:2.3.2
  request_repeater:
    image: 'candy/request_repeater:0.1'
    links:
      - nginx:development.candy
    environment:
      URLS: '{"urls": [{"url":"https://development.candy/some-endpoint", "sleep":1700},{"url":"https://development.candy/maintenance","sleep":7200}]}'
  candy_webserver:
    build: &webserver_build_vars
      context: .
      dockerfile: Dockerfile-development
    image: candycom_development
    #image: quay.io/candy/candycom:live-xxxxxxx_xxxx
    environment: &webserver_enviroment_vars
      #RAILS_ENV: production
      RAILS_ENV: development
      RAILS_LOG_LEVEL: info
      AIRBRAKE_API_KEY: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxdummyxxxxx
      CONTAINER_ROLE: 'webserver'
      MAX_THREADS: 2    # watch out so you don't run out of DB connection pool
      WEB_CONCURRENCY: 1 # should match your CPU
      SECRET_KEY_BASE: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

      DB_ENV_POSTGRES_PASSWORD: candy
      DB_ENV_POSTGRES_USERNAME: candy
      DB_ENV_POSTGRES_DATABASE: development_candy
      DB_PORT_5432_TCP_ADDR: db
      DB_PORT_5432_TCP_PORT: 5432

      REDIS_DB_ID: 0 # id of redis db
      REDIS_CACHE_PORT_6379_TCP_ADDR: redis
      REDIS_CACHE_PORT_6379_TCP_PORT: 6379
      REDIS_PORT_6379_TCP_ADDR: redis
      REDIS_PORT_6379_TCP_PORT: 6379
      ELASTICSEARCH_PORT_9200_TCP_ADDR: elasticsearch

      ACCOUNTS_API_URL: 'https://candy-accounts.fake/v1/'

    volumes_from:
      - box
    volumes:
      - .:/app
    links: &webserver_links
      - db:db
      - redis:redis
      #- accounts_webserver:accounts_webserver
    depends_on:
      - box
      - nginx
      - db
      - elasticsearch
  candy_background_job: &BACKGROUND_JOB_CONF
    #build:
      #<<: *webserver_build_vars
    image: candycom_development
    environment:
      <<: *webserver_enviroment_vars
      CONTAINER_ROLE: 'background_job'
      MAX_THREADS: 5    # watch out so you don't run out of DB connection pool
      WEB_CONCURRENCY: 1 # should match your CPU
      SECRET_KEY_BASE: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    volumes_from:
      - box
    volumes:
      - .:/app
    links: *webserver_links
    depends_on:
      - box
      - nginx
      - db
      - elasticsearch
      - candy_webserver
  #candy_background_job_2:
    #<<: *BACKGROUND_JOB_CONF


  #accounts_db:
    #image: postgres:9.4.5
    #environment:
      #POSTGRES_PASSWORD: candy
      #POSTGRES_USER: candy
      #POSTGRES_DB: candy_accounts_development
  #accounts_redis:
    #image: redis:2.8
  #accounts_box:
    #image: busybox
    #volumes:
      #- /shared/logs
      #- /shared/sockets
      #- /shared/pids
      #- ./log/:/shared/logs/
  #accounts_webserver:
    #ports:
      #- "3001:3001"
    #build: &accounts_webserver_build_vars
      #context: ../candy_accounts
      #dockerfile: ./Dockerfile-development
    #image: candycom_accounts_development
    #env_file:
      #- ../candy_accounts/.env
    #environment: &accounts_webserver_enviroment_vars
      #CONTAINER_ROLE: 'webserver'
      #RAILS_ENV: development
      #RACK_ENV: development
      #PORT: 3001
      #DB_POOL: 8
      #RAILS_MAX_THREADS: 2    # watch out so you don't run out of DB connection pool
      #SIDEKIQ_MAX_THREADS: 5
      #WEB_CONCURRENCY: 1 # should match your CPU

      #DATABASE_PASSWORD: candy
      #DATABASE_USERNAME: candy
      #DATABASE_DATABASE: candy_accounts_development
      #DATABASE_HOST: db

      #REDISTOGO_URL: 'redis://redis:6379'

      #CREDIT_DURATION_DAYS: '14'
    #volumes_from:
      #- accounts_box
    #volumes:
      #- ../candy_accounts:/app
    #links: &accounts_webserver_links
      #- accounts_db:db
      #- accounts_redis:redis
    #depends_on:
      #- accounts_box
      #- accounts_db
  #accounts_background_job:
    ##build:
      ##<<: *accounts_webserver_build_vars
    #image: candycom_accounts_development
    #env_file:
      #- ../candy_accounts/.env
    #environment:
      #<<: *accounts_webserver_enviroment_vars
      #CONTAINER_ROLE: 'background_job'
    #volumes_from:
      #- accounts_box
    #volumes:
      #- ../candy_accounts/:/app
    #links: *accounts_webserver_links
    #depends_on:
      #- accounts_box
      #- accounts_db
      #- accounts_webserver
```


Example 2

```
---
version: '2'
services:
  db_prod:
    image: postgres:9.4.5
    environment:
      POSTGRES_PASSWORD: candy
      POSTGRES_USER: candy
      POSTGRES_DB: development_candy
    volumes:
      - ./tmp/postgres/:/tmp/
      - ./docker/postgres/drop_db_and_restor_dump.sh:/tmp/drop_db_and_restor_dump.sh
  redis_prod:
    image: redis:2.8
  box:
    image: busybox
    volumes:
      - /var/www
      - /shared/logs
      - /shared/sockets
      - /shared/pids
      - /shared/certs
      - ./log/:/shared/logs/
      - ./db/development_certs/:/shared/certs/
  nginx:
    image: quay.io/candy/nginx.candy.com:live-20161117_asset_proxy
    #image: nginx.candy.com:test
    #build: &webserver_build_vars
      #context: /home/tomi/git/candy/nginx.candy.com
      #dockerfile: Dockerfile
    depends_on:
      - box
    volumes_from:
      - box
    ports:
      - "80:80"
      - "443:443"
  elasticsearch:
    image: elasticsearch:2.3.2
  request_repeater:
    image: 'equivalent/request_repeater:0.1'
    links:
      - nginx:development.candy
    environment:
      URLS: '{"urls": [{"url":"https://development.candy/some-endpoint", "sleep":1700},{"url":"https://development.candy/maintenance","sleep":7200}]}'
  candy_webserver:
    #image: quay.io/candy/candycom:live-xxxxxxx_xxxx
    image: candycom_localprod
    build:
      context: .
      dockerfile: Dockerfile
    environment: &webserver_enviroment_vars
      LOCALLY_RUNNED_DOCKER: 'true'
      RAILS_ENV: production
      RAILS_LOG_LEVEL: info
      CONTAINER_ROLE: 'webserver'
      MAX_THREADS: 2    # watch out so you don't run out of DB connection pool
      WEB_CONCURRENCY: 1 # should match your CPU
      SECRET_KEY_BASE: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

      DB_ENV_POSTGRES_PASSWORD: candy
      DB_ENV_POSTGRES_USERNAME: candy
      DB_ENV_POSTGRES_DATABASE: development_candy
      DB_PORT_5432_TCP_ADDR: db_prod
      DB_PORT_5432_TCP_PORT: 5432

      REDIS_DB_ID: 0 # id of redis db
      REDIS_CACHE_PORT_6379_TCP_ADDR: redis
      REDIS_CACHE_PORT_6379_TCP_PORT: 6379
      REDIS_PORT_6379_TCP_ADDR: redis
      REDIS_PORT_6379_TCP_PORT: 6379
      ELASTICSEARCH_PORT_9200_TCP_ADDR: elasticsearch

      #OTHER_MICROSERVICE_API_URL: 'http://other_microservice_webserver:3001/v1/'

    volumes_from:
      - box
    links: &webserver_links
      - db_prod:db
      - redis_prod:redis
      #- other_microservice_webserver:other_microservice_webserver
    depends_on:
      - box
      - nginx
      - db_prod
      - elasticsearch
  candy_background_job: &BACKGROUND_JOB_CONF
    #image: quay.io/candy/candycom:live-xxxxxxx_xxxx
    image: candycom_localprod
    environment:
      <<: *webserver_enviroment_vars
      CONTAINER_ROLE: 'background_job'
      MAX_THREADS: 5    # watch out so you don't run out of DB connection pool
      WEB_CONCURRENCY: 1 # should match your CPU
      SECRET_KEY_BASE: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    volumes_from:
      - box
    links: *webserver_links
    depends_on:
      - box
      - nginx
      - db_prod
      - elasticsearch
      - candy_webserver
  #candy_background_job_2:
    #<<: *BACKGROUND_JOB_CONF


  #other_microservice_db:
    #image: postgres:9.4.5
    #environment:
      #POSTGRES_PASSWORD: candy
      #POSTGRES_USER: candy
      #POSTGRES_DB: candy_other_microservice_development
  #other_microservice_redis:
    #image: redis:2.8
  #other_microservice_box:
    #image: busybox
    #volumes:
      #- /shared/logs
      #- /shared/sockets
      #- /shared/pids
      #- ./log/:/shared/logs/
  #other_microservice_webserver:
    #ports:
      #- "3001:3001"
    #build: &other_microservice_webserver_build_vars
      #context: ../candy_other_microservice
      #dockerfile: ./Dockerfile-development
    #image: candycom_other_microservice_development
    #env_file:
      #- ../candy_other_microservice/.env
    #environment: &other_microservice_webserver_enviroment_vars
      #CONTAINER_ROLE: 'webserver'
      #RAILS_ENV: development
      #RACK_ENV: development
      #PORT: 3001
      #DB_POOL: 8
      #RAILS_MAX_THREADS: 2    # watch out so you don't run out of DB connection pool
      #SIDEKIQ_MAX_THREADS: 5
      #WEB_CONCURRENCY: 1 # should match your CPU

      #DATABASE_PASSWORD: candy
      #DATABASE_USERNAME: candy
      #DATABASE_DATABASE: candy_other_microservice_development
      #DATABASE_HOST: db

      #REDISTOGO_URL: 'redis://redis:6379'

    #volumes_from:
      #- other_microservice_box
    #volumes:
      #- ../candy_other_microservice:/app
    #links: &other_microservice_webserver_links
      #- other_microservice_db:db
      #- other_microservice_redis:redis
    #depends_on:
      #- other_microservice_box
      #- other_microservice_db
  #other_microservice_background_job:
    ##build:
      ##<<: *other_microservice_webserver_build_vars
    #image: candycom_other_microservice_development
    #env_file:
      #- ../candy_other_microservice/.env
    #environment:
      #<<: *other_microservice_webserver_enviroment_vars
      #CONTAINER_ROLE: 'background_job'
    #volumes_from:
      #- other_microservice_box
    #volumes:
      #- ../candy_other_microservice/:/app
    #links: *other_microservice_webserver_links
    #depends_on:
      #- other_microservice_box
      #- other_microservice_db
      #- other_microservice_webserver
```

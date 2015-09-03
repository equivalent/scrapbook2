


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
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
RUN bundle install
ADD . /myapp
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








# sources and references:

[1]: https://www.youtube.com/watch?v=ddhU3NMrhX4 "3 hours to docker fundaments"
[2]: https://www.youtube.com/watch?v=JBtWxj9l7zM  "Docker Tutorial - Docker Container Tutorial for Beginners"
[3]: https://docs.docker.com/compose/rails/  "docker composer rails"


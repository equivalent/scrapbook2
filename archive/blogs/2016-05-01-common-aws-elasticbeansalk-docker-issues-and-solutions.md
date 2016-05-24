# Common AWS Elastic Beanstalk Docker issues and solutions.

## Debugging Tools and files

#### eb console

AWS Elastic Beanstalk provides [EB CLI](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html)
`$ eb` from which you can do lot of debugging operations. All you need
is to `cd` to the directory where you hold `Dockerrun.aws.json` file and
lunch it from there

```bash
cd ~/folder_where_I_hold_Dockerrunjson/

eb deploy
# will `tar` the dir and deploy it to AWS EB = it will deploy your app

eb status
# Environment details for: myApplication
#   # ....
#   Status: Ready  # when `Updating` it means that either deployment running or some env config is beeing updated you need to wait while  finishes
#   Health: Green  # when `Red` it means that either load balancer cannot access it or the instance is down. Sometimes it happens when CPU is to high

eb events -f
# events that are currently happening on that server e.g.:
# Deploying new version to instance(s).                                  - deployment in progress 
# Batch 3: Starting application deployment on instance(s) [i-fe87ae73]   - what instance is beeing update

eb ssh
# ssh to the instance. 
```

> note: `eb ssh` will work only if you have private key that is allowed
> to access  to server is your `~/.ssh/` dir and you specify the name of that ssh
> key in `folder_with_dockerrun_json/.elasticbeanstalk/config.yml` in
> `default_ec2_keyname`. Look at articles Appending Example 1

#### Important log files

ssh to AWS instance (`eb ssh`)

* `/var/app/current/Dockerrun.aws.json` - view currently deployed EB
  configuration file
* `/var/log/eb-activity.log` - log files of AWS events such as steps
  that are done in order to downloading credentials, pull Docker images,
as well as hook methods.
* `/var/log/docker` and `/var/log/docker-events` - what is happening
  with docker images after `eb-activity` finishes - e.g. starting
containers, die, ...
* `~/shared/logs/` - `rails` and `nginx` logs 

## Restarting a server

AWS ElasticBeanstalk VMs are configured in a way that it should be ok to
restart them at any point. (all configuration is remembered unless your
DevOps guy is done some custom changes)

```
eb ssh

# once in 
sudo shutdown -r now
```

## Common server issues when docker is not starting

Let say for no good reason (or after deployment) docker containers seems
to start and die

```
tail -f -n 333 /var/log/docker-events.log

# something like :
# 2016-05-12T00:50:48.000000000Zddbde24a9b7dbf5156f1e74cd0d5f0e7463e49f3435c5b9423a5fba0969f3735: (fromequivalent/my_docker_app) start
# 2016-05-12T00:50:49.000000000Zddbde24a9b7dbf5156f1e74cd0d5f0e7463e49f3435c5b9423a5fba0969f3735: (fromequivalent/my_docker_app) die
# 2016-05-12T00:51:48.000000000Zddbde24a9b7dbf5156f1e74cd0d5f0e7463e49f3435c5b9423a5fba0969f3735: (fromequivalent/my_docker_app) start
# 2016-05-12T00:51:49.000000000Zddbde24a9b7dbf5156f1e74cd0d5f0e7463e49f3435c5b9423a5fba0969f3735: (fromequivalent/my_docker_app) die
```

#### Server run out of space

check space usage


```bash
df -h

# Filesystem      Size  Used Avail Use% Mounted on
#  /dev/xvda1       30G  24G   25G  99% /
#  devtmpfs        2.0G  112K  2.0G   1% /dev
#  tmpfs           2.0G     0  2.0G   0% /dev/shm
```

check particular folder

```
sudo du -sh /var/log
# 49G    /var/log

```

docker images may be takeing too much space 

```
sudo du -sh /var/lib/docker/
13G/var/lib/docker/

sudo du -sh /var/
sudo docker rmi -f $(sudo docker images | grep "<none>" | awk "{print\$3}") # Get rid of all untagged images.
```

> I'm recommending to check
> http://www.eq8.eu/blogs/23-spring-cleaning-for-webdevelopers 

#### Image doesn't exist

First just check `cat /var/app/current/Dockerrun.aws.json` and if the
`image` specified in it is the one you want.

 In 90% cases the docker would be
failing just because you mistyped image name (e.g.
`"image":"quay.io/myorg/myapp:live_20160101,",`)

If the `tail -n 333 -f /var/log/eb-activity.log` is saying something
like "Docker image not found" or "You don't have permissions to access
this image" it's usually due this:

* misspelled docker image / endpoint (e.g.
  `"image":"quay.io/myorg/myapp:live_20160101,",`
* wrong credential file name in the `Dockerrun.aws.json`  (look at
  Appending Example 2)
* credentials inside the bucket are not correct (look at Appending
  Example 3)

#### Out of memory

let say that `/var/log/docker-events` have something like 

```
2016-05-12T00:51:01.000000000Z4edd70df83997cdd5487a684b7a1ae2021072627efa7d1db909bb4270d36fbf4: (fromequivalent/little_bastard:latest) start
2016-05-12T03:31:42.000000000Zedcdaf5426465b92519df0b81a3706d0033c329cd2d7aaddf5c4bb7f2ee9752e: (fromequivalent/little_bastard:latest) oom  # <<< !!!! important
2016-05-12T03:31:42.000000000Zedcdaf5426465b92519df0b81a3706d0033c329cd2d7aaddf5c4bb7f2ee9752e: (fromequivalent/little_bastard:latest) die
```

...the `oom` means that docker image `equivalent/little_bastard` don't
have enough memory allocated

Solution: in the ElasticBeanstalk application environment
`Dockerrun.aws.json` 

```
  "containerDefinitions": [
    {
      "name": "request_repeater",
      "image": "equivalent/little-bastard",
      "essential": true,
      "memory": 80,
```

...increase the  memory allocation (`"memory": 80 to e.g. "memory: 100)


## Appendix

#### Example 1 `.elasticbeanstalk/config.yml`

```
branch-defaults:
  default:
    environment: name-of-my-enviroment-qa
  production
    environment: name-of-my-enviroment-production
global:
  application_name: Production myapp.com
  default_ec2_keyname: myapsecretkey
  default_platform: Multi-container Docker 1.6.2 (Generic)
  default_region: us-east-1
  profile: eb-cli
  sc: null
```

#### Example 2  -  authentication in Dockerrun.aws.json

```
  # ...
  "authentication": {
    "bucket": "myapp.com.systems",
    "key": "dockercfg"
  },
  # ...
```

#### Example 3 - corrent credentials inside bucket file

if you use quay.io

```
{
  "auths": {
    "quay.io": {
      "auth":"ZxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxT0=",
      "email": "admin@myapp.com"
    }
  }
}

if you use dockerhub

{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "Zxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxq",
      "email": "admin@myapp.com"
    },
  }
}
```

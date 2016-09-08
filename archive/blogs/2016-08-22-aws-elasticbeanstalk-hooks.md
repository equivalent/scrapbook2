# AWS ElasticBeanstalk deployment hooks

...or: How to run a script after Elastic Beanstalk deployment finishes.

In this article we will have a look on [AWS ElasticBeanstalk](https://aws.amazon.com/elasticbeanstalk/) post/pre deployment script running.

I will assume you know how [`eb` CLI](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3.html) works,
I assume you know how to use  `eb deploy` to do  the deployment
and I assume you are executing command from a folder where is your `.elasticbeanstalk/config.yml` (or `Dockerrun.aws.json`)

> I will be updating this article each time I learn a new trick related to `.ebextensions` or come up with new example

## Using Post deployment hook folder

[AWS ElasticBeanstalk](https://aws.amazon.com/elasticbeanstalk/)  provides "hooks" folders that you can configure
to run various scripts before/after deployment

I will not go into depth but in short:  in you EC2 instance provisioned by AWS ElasticBeanstalk you have a folders:

```bash
/opt/elasticbeanstalk/hooks/appdeploy/pre/       # before deployment
/opt/elasticbeanstalk/hooks/appdeploy/post/      # after deployment
```

> note: if you don't have them you can create them.

Here you can create file e.g. `91_run_something_after_deploymnet.sh`. Notice the number in the beginning  of the file name.
That is important as EB will execute the scripts in order of names and some AWS built in system names are `01_...`, `02_...`
and you don't want them to be skipped with your script


Now if you don't have to write a script manually to every EC2 instance, all you have to do is to create file in `.ebextension` folder
in the folder from which you are executing `eb deploy`: 


Content of `.ebextensions/91_run_something_after_deploymnet.config`

```bash
files:
  "/opt/elasticbeanstalk/hooks/appdeploy/post/91_run_something_after_deploymnet.sh":
    mode: "000755"
    owner: root
    group: root
    content: |
      mail -s 'Starting deploymnet !!!' "admin@my-website.com" < /dev/null
```

> note `.ebextension/*.config` are also executed in alphabetic order, it's considered good practice to name them `%d%d_name_of_script.config`


Now each time you deploy or a new EC2 instance is introduced `/opt/elasticbeanstalk/hooks/appdeploy/post/91_run_something_after_deploymnet.sh`
with this content will be created => you will have after hook script.

**NOTE !!!** if you rename your hook file to something else in `.ebextensions`, or you remove it from `.ebextensions` be sure you write
a script that will remove the file from from this server folder  ( or ssh in and remove the script file manually).
`.ebextensions`  will not delete old files automatically !!! You may end
up with old script still being executed on old Instances even if it's
not in `.ebextensions` folder.


Related articles that contains more info:

* http://www.dannemanne.com/posts/post-deployment_script_on_elastic_beanstalk_restart_delayed_job
* http://junkheap.net/blog/2013/05/20/elastic-beanstalk-post-deployment-scripts/
* http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/ebextensions.html


## Direct .ebextension command enxecution

You can specify `.ebextension/01_some-name.config` to have command like:

```
commands:
  99_write_post_provisioning_complete_file:
    command: touch /opt/elasticbeanstalk/.post-provisioning-complete
```

or

```
container_commands:
  01install-node:
    command: PATH=/usr/local/bin:$PATH bash touch /tmp/aaaaa
```

Be careful doh. I've learned the hard way that this commands are executed only in certain stage of deployment process. So if you're running
Docker EB environment some parts of your application may not be ready yet (e.g. containers)

So if you need something  after deployment is finished you won't be able to do that from here. I recommend using the **folder hooks** mentioned above.

> I've read in some StackOverflow answer that folder hooks are deprecated and `commands` should be used. Don't believe that, they are not
> deprecated and it looks like they never will be as the entire AWS EB flow works is folder hooks. `commands` are just more recommended in some cases.
> I honestly don't use commands anymore as `.ebextensions` scenarios that I'm dealing with require folder hooks, so if you find any error in
> syntax above please let me know.
>
> **update** I don't have any link to  official AWS statment on this
> as AWS documentation on this topic is minimal or not existing. The only reason I'm pretty sure this will not
> be deprecated is if you watch /var/log/eb-activity.log you can see bunch
> of hook folders being executed and most of them are AWS EB essential.


Related articles

* http://stackoverflow.com/questions/14077095/aws-elastic-beanstalk-running-a-cronjob


## Execution only on one instance.

Let say you have load balanced environment with 10 EC2 instances and you want to execute some script after deployment only on one of them.

`.ebextensions` provide `leader_only` option which means "run only on leader instance"


```bash
container_commands:
  09_some_task_on_primary_instance_only:
    command: "touch /tmp/abc"
    leader_only: true
```

> Developer may be tempted to put a cron job into this task but (as it
> was pointed out to me in [this post](https://www.reddit.com/r/aws/comments/4z0jff/aws_elasticbeanstalk_deployment_hooks/)) it's
> considered bad practice to put cron jobs to loadbalanced environments as
> the instance may die/is removed -> your essential task may not run
> overnight. Check [AWS Lambda Scheduling](http://docs.aws.amazon.com/lambda/latest/dg/with-scheduled-events.html)
> or [this](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features-managing-env-tiers.html) and [this](https://medium.com/@joelennon/running-cron-jobs-on-amazon-web-services-aws-elastic-beanstalk-a41d91d1c571#.7cywqjukt) article for how to do it with Worker instance.


* http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/customize-containers-ec2.html  search for leader_only
* http://stackoverflow.com/questions/14077095/aws-elastic-beanstalk-running-a-cronjob

## Many possible hooks

As user  [Froyoforever](https://www.reddit.com/user/Froyoforever) kindly pointed out in [this Reddit Discussion](https://www.reddit.com/r/aws/comments/4z0jff/aws_elasticbeanstalk_deployment_hooks/d6tb57j), one danger here is that different hook directories get called for different events. There's `appdeploy`, `configdeploy`, `restartappserver`, `postinit`, `preinit`, etc.

> Just do `ls /opt/elasticbeanstalk/hooks/` to list them all

Unfortunately I can only speak for `appdeploy` as it's the only one that I've used.
I'll let you figure out what is what if you need them.


## Example 1 - load SSL certificate from S3

...after deployment or when new instance is added

You probably have AWS load balancer and threfore you have your SSL certificates uploaded there.
 But let say you have `Nginx` container running on you EC2 instance to proxy some routes/headers before going
to actual web server (e.g. `AWS Load balancer` > `Nginx` > `Unicorn/Puma server` > `Ruby on Rails app`

Now you need to be able to use those ssl certificates in in your Docker containers.

Solution:

1. configure your Nginx `Docker.aws.json` so that you share common folder (e.g. Host `~/shared/certs/` to Container `/shared/certs/`)
2. configure your Nginx to use ssl cert from Docker container folder `/shared/certs/ssl.crt` and key form `/shared/certs/ssl.key` ([how to do that](https://github.com/equivalent/scrapbook2/blob/master/nginx.md))
3. AWS EB  provides a AWS S3 Bucket that all your environment instances have
   access to download configuration files. Upload your SSL certificates to
   this this bucket (e.g. `s3://my-app-bucket.com.systems/ssl/production/my-app.crt`)
4. create `.ebextensions/50_pull_ssl_certificates_files.config` (bellow)
5. git commit, push  and redeploy with `eb deploy`



Content of `.ebextensions/50_pull_ssl_certificates_files.config`

```bash
files:
  "/opt/elasticbeanstalk/hooks/appdeploy/post/50_pull_ssl_certificate_files.sh":
    mode: "000755"
    owner: root
    group: root
    content: |
      #!/usr/bin/env bash
      environment="production"
      cert="$my-app.chain.crt"
      key="$my-app.key"
      /usr/bin/aws s3 --region eu-west-1 cp s3://my-app-bucket.com.systems/ssl/${environment}/${cert} /home/ec2-user/shared/certs/ssl.crt
      /usr/bin/aws s3 --region eu-west-1 cp s3://my-app-bucket.com.systems/ssl/${environment}/${key} /home/ec2-user/shared/certs/ssl.key

```

After deployment this will create `/opt/elasticbeanstalk/hooks/appdeploy/pre/50_pull_ssl_certificate_files.sh` on your EC2 instance with content:

```bash
environment="production"
cert="my-app.chain.crt"
key="my-app.key"
/usr/bin/aws s3 --region eu-west-1 cp s3://my-app-bucket.com.systems/ssl/${environment}/${cert} /home/ec2-user/shared/certs/ssl.crt
/usr/bin/aws s3 --region eu-west-1 cp s3://my-app-bucket.com.systems/ssl/${environment}/${key} /home/ec2-user/shared/certs/ssl.key
```

> Note: it may be good idea to encrypt your key on S3 Bucket and then decrypt it in a NginX docker image using OpenSSL. You can set the
> decryption password as ENV variable in EB  web console.


Credits: 

* result of collaborative work of  [Luke Hansbury](https://github.com/lhansbury) & EquiValent





## Example 2 - run reindex ElasticSearch after deployment (Ruby on Rails Docker)

Let say we have Ruby on Rails application in a Docker container (named `rails-app`)

Imagine that you want to run a script that will reindex the
Elasticsearch after deployment to test / QA environment.

Content of `.ebextensions/90_create_reindex_elastic_cache_file.config` :

```bash
files:
  "/opt/elasticbeanstalk/hooks/appdeploy/post/90_reindex_elastic_cache.sh":
    mode: "000755"
    owner: root
    group: root
    content: |
      #!/usr/bin/env bash
      rails_container_id=$(docker ps | grep -e rails-[^r] | awk '{print$1;}') && docker exec -d $rails_container_id rake reindex

```

First we will fetch the container ID of Ruby on Rails instance and we
will run demonized `rake reindex` command on that Docker container

`rake reindex` have content:

```ruby
#lib/tasks/elasticserach.rake

task reindex: :environment do
  MyModel.__elasticsearch__.create_index!
end
```

#### Related resources

* [AWS Reddit discussion on this article](https://www.reddit.com/r/aws/comments/4z0jff/aws_elasticbeanstalk_deployment_hooks/)
* [Common AWS Elastic Beanstalk Docker issues and solutions](http://www.eq8.eu/blogs/25-common-aws-elastic-beanstalk-docker-issues-and-solutions)

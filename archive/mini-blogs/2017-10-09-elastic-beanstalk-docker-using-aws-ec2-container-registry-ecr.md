# Elastic Beanstalk Docker using AWS EC2 Container Registry (ECR)

This T.I.L. note deals with topic of  Docker Registry credentials/authorization options when you use [AWS Elastic Beanstalk (EB)](https://aws.amazon.com/elasticbeanstalk/) as a [Multicontainer Docker](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html#create_deploy_docker_ecs_platform). If you need more info check [this](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html#create_deploy_docker_ecs_platform) article or FAQ links bellow.


### 3rd party Docker registry provider

> I'm placing this here just to show difference of setup between 3rd
> party Docker Registry and native AWS Docker Registry (ECR)

If you use Dockerhub or Quay.io as your Docker registry you need to
place "authentication" block in your Dockerrun.aws.json. Inside that you
provide the S3 bucket (`bucket`) from which the EB agent pull a file (`key`) during deployment.


```json
# Dockerrun.aws.json
{
  "AWSEBDockerrunVersion": 2,
  "authentication": {
    "bucket": "mybucketfullofsecrets",
    "key": "dockercfg-myawesomeapp"
  },
  "containerDefinitions": [
     {
       "name": "rails",
       "image": "myawesomecompany/myawesomesecretproject:latest",
       # ...
     }
   ]
}
```

You need to make sure that EB instance can access to the bucket, and
instance is able to
download the credential file (`Grant permissions for the s3:GetObject
operation to the IAM role in the instance profile`) and bucket needs to
be in same region as EB.

> Full steps are out of the scope for this T.I.L. note
> Further information can be found here:
> http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker.container.console.html#docker-images-private


Credential file `dockercfg-myawesomeapp` looks something like this:

```

{
  "auths" :
  {
    "https://index.docker.io/v1/": {
      "auth" : "auth_token",
      "email" : "email"
    },
    "quay.io": {
      "auth": "dGrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrN3",
      "email": "foo@bar.com"
    }
  }
}
```

> This file is similar to your local `./docker/config.json`


### AWS EC2 Container Registry

AWS has a Docker Registry product [ECR](https://aws.amazon.com/ecr/).
When configuring it with your EB **you don't need** to provide the `authentication`
block in your `Dockerrun.aws.json` and no upload of credentials to S3
bucket.

> In fact I found out that if I do all the other remaining steps for ECR
> but still leave the authentication section in my `Dockerun.aws.json`
> then docker pull from ECR is not working !


```json
{
  "AWSEBDockerrunVersion": 2,
  "containerDefinitions": [
     {
       "name": "rails",
       "image": "666666666666.dkr.ecr.eu-west-1.amazonaws.com/myawesomesecretproject:latest",
       # ...
     }
   ]
}
```

Only thing you need to do is to allow your EB "instance profile role" to has
[AmazonEC2ContainerRegistryReadOnly](http://docs.aws.amazon.com/AmazonECR/latest/userguide/ecr_managed_policies.html#AmazonEC2ContainerRegistryReadOnly) policy

Steps:


##### step 1 -  Create AWS ECR docker Registry 

```
AWS Web console > EC2 Container Service (ECS) > Repositories > Create repository
```

Note: you need to create it in same AWS region as EB

##### step 2 - To find out What is "instance profile role" for my EB Environment

```
AWS Web console > Elastic Beanstalk > Your environment > Configuration > Instances > Instance profile (that's the value)


e.g.: aws-elasticbeanstalk-ec2-role
```

##### step 3 - To add AmazonEC2ContainerRegistryReadOnly policy


```
AWS Web console > IAM > Roles > Role (e.g. aws-elasticbeanstalk-ec2-role) > Attach policy >  AmazonEC2ContainerRegistryReadOnly 
```


##### step 4 - Add access inside the ECR

Although the official EB ECR is not saying this, you may need to "allow"
the instance profile on the ECR side too


```
AWS Web console > EC2 Container Service (ECS) > Repositories > Repository (e.g. myawesomesecretproject) > permissions
```

...add add a permission from the webinterface tool. Search for your EB
role (e.g.: aws-elasticbeanstalk-ec2-role) and add all read only
permissions to the Repository


## Build & push to ECR

Give you want to build and push your docker image on from your laptop

via AWS CLI you need to run:

```
aws ecr get-login
```

> Credentials in your laptop must have permissions for ECR

and run the output of that command 

```
docker login -u AWS -p xxxxxxxxxxxxxxxxxxxxxx -e none https://666666666666.dkr.ecr.eu-west-1.amazonaws.com
```

this will add an authorization entrie to your `~/.docker/config.json` for ECR registry


Now you are able to build and push 


```bash

docker build -t=666666666666.dkr.ecr.eu-west-1.amazonaws.com/myawesomesecretproject:latest .
docker push 666666666666.dkr.ecr.eu-west-1.amazonaws.com/myawesomesecretproject:latest
docker pull 666666666666.dkr.ecr.eu-west-1.amazonaws.com/myawesomesecretproject:latest

```

Now be careful now. It seems that the credential details generated by `aws ecr get-login` expire in some time.
So if you have a build VM it may be worth to automatically generate and
store  the credentials via cronjob


```
crontab -e
```

add 

```
0 * * * *  sudo -u ubuntu `aws ecr get-login`
```

this will run aws cli command to get and execute the command as a user `ubuntu` every hour

> note by using backtick execution you can potentionaly introduce
> security risk to your build machine as you will execute whatever the
> `aws ecr` command returns. Feel free to alter this command
> in more secure way



## FAQ & related articles

* [AWS Elastic Beanstalk  Docker Rails](https://www.youtube.com/watch?v=xhEyUYTuSQw&t=42s) example
* [How does the Dockerrun.aws.json look like](https://github.com/equivalent/docker_rails_aws_elasticbeanstalk_demmo_app/blob/master/aws_elastic_beanstalk/Dockerrun.aws.json)

* [AWS EC2 Container Registry  (ECR)](https://aws.amazon.com/ecr/)
* http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker.container.console.html


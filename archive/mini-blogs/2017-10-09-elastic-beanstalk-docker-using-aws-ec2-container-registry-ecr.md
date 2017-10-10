# Elastic Beanstalk Docker using AWS EC2 Container Registry (ECR)

This T.I.L. note deals with topic of  Docker Registry credentials/authorization options when you use [AWS Elastic Beanstalk (EB)](https://aws.amazon.com/elasticbeanstalk/) as a [Multicontainer Docker](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html#create_deploy_docker_ecs_platform). If you need more info check [this](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html#create_deploy_docker_ecs_platform) article or FAQ links bellow.


### 3rd party Docker registry provider

If you use Dockerhub or Quay.io as your Docker registry you need to
place "authentication" block in your Dockerrun.aws.json. Inside that you
provide the S3 bucket (`bucket`) from which the EB agent pull a file (`key`) during deployment.


```json
# Dockerrun.aws.json
{
  "AWSEBDockerrunVersion": 2,
  "authentication": {
    "bucket": "pobble.com.systems",
    "key": "dockercfg-pobblebot"
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

You need to make sure that EB instance can access to the bucket able to
pull the credential file (`Grant permissions for the s3:GetObject
operation to the IAM role in the instance profile`) and bucket needs to
be in same region as EB. This is out of the scope for this T.I.L. note
Further information can be found here:
http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker.container.console.html#docker-images-private


Credential file looks something like this:

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
       "image": ""666666666666.dkr.ecr.eu-west-1.amazonaws.com/myawesomesecretproject:latest",
       # ...
     }
   ]
}
```

Only thing you need to do is to allow your EB "instance profile role" to has
[AmazonEC2ContainerRegistryReadOnly](http://docs.aws.amazon.com/AmazonECR/latest/userguide/ecr_managed_policies.html#AmazonEC2ContainerRegistryReadOnly) policy

Steps:


##### 0  Create AWS ECR docker Registry 

```
AWS Web console > EC2 Container Service (ECS) > Repositories > Create repository
```

Note: you need to create it in same AWS region as EB

##### 1 To find out What is "instance profile role" for my EB Environment

```
AWS Web console > Elastic Beanstalk > Your environment > Configuration > Instances > Instance profile (that's the value)


e.g.: aws-elasticbeanstalk-ec2-role
```

##### 2 To add AmazonEC2ContainerRegistryReadOnly policy


```
AWS Web console > IAM > Roles > Role (e.g. aws-elasticbeanstalk-ec2-role) > Attach policy >  AmazonEC2ContainerRegistryReadOnly 
```


##### 3 Add access inside the ECR

Although the official EB ECR is not saying this, you may need to "allow"
the instance profile on the ECR side too


```
AWS Web console > EC2 Container Service (ECS) > Repositories > Repository (e.g. myawesomesecretproject) > permissions
```

...add add a permission from the webinterface tool. Search for your EB
role (e.g.: aws-elasticbeanstalk-ec2-role) and add all read only
permissions to the Repository


## FAQ & related articles

* [AWS Elastic Beanstalk  Docker Rails](http://www.eq8.eu/talks/2-aws-elastic-beanstalk-docker-for-rails-developers) example
* [How does the Dockerrun.aws.json look like](https://github.com/equivalent/docker_rails_aws_elasticbeanstalk_demmo_app/blob/master/aws_elastic_beanstalk/Dockerrun.aws.json)

* [AWS EC2 Container Registry  (ECR)](https://aws.amazon.com/ecr/)
* http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker.container.console.html

